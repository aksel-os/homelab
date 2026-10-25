{
  config,
  self,
  pkgs,
  ...
}:

let
  inherit (config.sops) templates;
  inherit (config.virtualisation.quadlet) networks;

in
{
  sops.secrets = {
    "firefly/db_password".sopsFile = "${self}/secrets/services/firefly.yaml";
    "firefly/app_key".sopsFile = "${self}/secrets/services/firefly.yaml";
  };

  sops.templates."firefly-db.env" = {
    content = ''
      POSTGRES_PASSWORD=${config.sops.placeholder."firefly/db_password"}
    '';
    restartUnits = [ "firefly-db.service" ];
  };

  sops.templates."firefly.env" = {
    content = ''
      APP_KEY=${config.sops.placeholder."firefly/app_key"}
      DB_PASSWORD=${config.sops.placeholder."firefly/db_password"}
    '';
    restartUnits = [ "firefly.service" ];
  };

  virtualisation.quadlet.containers.firefly-db = {
    containerConfig = {
      image = "docker.io/postgres:18.3-alpine";
      networks = [ networks.dns.ref ];

      environmentFiles = [ templates."firefly-db.env".path ];
      environments = {
        POSTGRES_DB = "firefly";
        POSTGRES_USER = "firefly";
      };

      volumes = [ "/var/lib/firefly/postgres:/var/lib/postgresql" ];

      healthCmd = "pg_isready -U firefly -d firefly";
      healthInterval = "10s";
      healthTimeout = "5s";
      healthRetries = 10;
      healthStartPeriod = "20s";
      notify = "healthy";
    };
  };

  virtualisation.quadlet.containers.firefly = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.firefly.rule=Host(`firefly.internal.akselos.no`)"
        "traefik.http.routers.firefly.entrypoints=websecure"
        "traefik.http.routers.firefly.tls=true"
        "traefik.http.routers.firefly.tls.certresolver=letsencrypt"
        "traefik.http.services.firefly.loadbalancer.server.port=8080"
        "traefik.http.routers.firefly.middlewares=purescale@file"
      ];

      image = "docker.io/fireflyiii/core:version-6.7.9";
      networks = [ networks.dns.ref ];

      environmentFiles = [ templates."firefly.env".path ];
      environments = {
        TZ = config.time.timeZone;
        APP_URL = "https://firefly.internal.akselos.no";
        TRUSTED_PROXIES = "**";
        DB_CONNECTION = "pgsql";
        DB_HOST = "firefly-db";
        DB_PORT = "5432";
        DB_DATABASE = "firefly";
        DB_USERNAME = "firefly";
      };

      volumes = [ "/var/lib/firefly/upload:/var/www/html/storage/upload" ];
    };

    unitConfig = {
      After = [ "firefly-db.service" ];
      Requires = [ "firefly-db.service" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/firefly/postgres 0750 70 70 -"
    "d /var/lib/firefly/upload 0755 33 33 -"
  ];

  # DB backup: pg_dump streamed straight into its own restic repo
  services.restic.backups.firefly-db = {
    repository = "/mnt/backups/restic/firefly-db";
    passwordFile = config.sops.secrets."restic/repository_password".path;
    initialize = true;

    command = [
      "${pkgs.podman}/bin/podman"
      "exec"
      "firefly-db"
      "pg_dump"
      "-U"
      "firefly"
      "firefly"
    ];
    extraBackupArgs = [ "--stdin-filename=firefly.sql" ];

    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "30m";
      Persistent = true;
    };

    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];
  };

  services.restic.backups.apps.paths = [ "/var/lib/firefly/upload" ];

  # # OPTIONAL: recurring transactions, auto-budgets, bill warnings
  # systemd.services.firefly-cron = {
  #   serviceConfig.Type = "oneshot";
  #   script = "${pkgs.podman}/bin/podman exec --user www-data firefly /usr/local/bin/php /var/www/html/artisan firefly-iii:cron";
  # };
  # systemd.timers.firefly-cron = {
  #   wantedBy = [ "timers.target" ];
  #   timerConfig = {
  #     OnCalendar = "*-*-* 03:00:00";
  #     Persistent = true;
  #   };
  # };
}
