{
  config,
  self,
  pkgs,
  ...
}:

let
  inherit (config.sops) templates;
  inherit (config.virtualisation.quadlet) networks;

  rommConfig = (pkgs.formats.yaml { }).generate "romm-initial-config.yml" {
    filesystem = {
      structure = {
        default = "roms/{platform}/{game}";
        firmware = "bios/{platform}";
      };
    };
  };
in
{
  sops.secrets = {
    "romm/db_password".sopsFile = "${self}/secrets/services/romm.yaml";
    "romm/auth_secret_key".sopsFile = "${self}/secrets/services/romm.yaml";
    "romm/mariadb_root_password".sopsFile = "${self}/secrets/services/romm.yaml";
    "romm/igdb_client_id".sopsFile = "${self}/secrets/services/romm.yaml";
    "romm/igdb_client_secret".sopsFile = "${self}/secrets/services/romm.yaml";
    "romm/steamgriddb_api_key".sopsFile = "${self}/secrets/services/romm.yaml";
    "romm/retroachievements_api_key".sopsFile = "${self}/secrets/services/romm.yaml";
  };

  sops.templates."romm.env" = {
    content = ''
      DB_PASSWD=${config.sops.placeholder."romm/db_password"}
      ROMM_AUTH_SECRET_KEY=${config.sops.placeholder."romm/auth_secret_key"}
      IGDB_CLIENT_ID=${config.sops.placeholder."romm/igdb_client_id"}
      IGDB_CLIENT_SECRET=${config.sops.placeholder."romm/igdb_client_secret"}
      STEAMGRIDDB_API_KEY=${config.sops.placeholder."romm/steamgriddb_api_key"}
      RETROACHIEVEMENTS_API_KEY=${config.sops.placeholder."romm/retroachievements_api_key"}
    '';
    restartUnits = [ "romm.service" ];
  };

  sops.templates."romm-db.env" = {
    content = ''
      MARIADB_ROOT_PASSWORD=${config.sops.placeholder."romm/mariadb_root_password"}
      MARIADB_PASSWORD=${config.sops.placeholder."romm/db_password"}
    '';
    restartUnits = [ "romm-db.service" ];
  };

  virtualisation.quadlet.containers.romm-db = {
    containerConfig = {
      image = "docker.io/mariadb:11.4";
      networks = [ networks.dns.ref ];

      environmentFiles = [ templates."romm-db.env".path ];
      environments = {
        MARIADB_DATABASE = "romm";
        MARIADB_USER = "romm";
      };

      volumes = [
        "/var/lib/romm/mariadb:/var/lib/mysql"
      ];

      healthCmd = "healthcheck.sh --connect --innodb_initialized";
      healthInterval = "10s";
      healthTimeout = "5s";
      healthStartPeriod = "30s";
      healthRetries = 5;
    };
  };

  virtualisation.quadlet.containers.romm = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.romm.rule=Host(`romm.internal.akselos.no`)"
        "traefik.http.routers.romm.entrypoints=websecure"
        "traefik.http.routers.romm.tls=true"
        "traefik.http.routers.romm.tls.certresolver=letsencrypt"
        "traefik.http.services.romm.loadbalancer.server.port=8080"
        "traefik.http.routers.romm.middlewares=purescale@file"
      ];

      image = "docker.io/rommapp/romm:5.3.0";
      networks = [ networks.dns.ref ];

      environmentFiles = [ templates."romm.env".path ];
      environments = {
        TZ = config.time.timeZone;
        DB_HOST = "romm-db";
        DB_NAME = "romm";
        DB_USER = "romm";

        ENABLE_RESCAN_ON_FILESYSTEM_CHANGE = "true";
        ENABLE_SCHEDULED_RESCAN = "true";
        SCAN_WORKERS = "4";
        WEB_SERVER_CONCURRENCY = "4";

        # Optional metadata providers
        # SCREENSCRAPER_USER = "";
        # SCREENSCRAPER_PASSWORD = "";
        # RETROACHIEVEMENTS_API_KEY = "";
        # STEAMGRIDDB_API_KEY = "";
        HASHEOUS_API_ENABLED = "true";
      };

      volumes = [
        "/var/lib/romm/resources:/romm/resources"
        "/var/lib/romm/redis-data:/redis-data"
        "/var/lib/romm/assets:/romm/assets"
        "/var/lib/romm/config:/romm/config"
        "/mnt/nas/media/roms:/romm/library"
      ];

      healthCmd = "curl -f http://localhost:8080/api/heartbeat || exit 1";
      healthInterval = "30s";
      healthTimeout = "10s";
      healthRetries = 3;
      healthStartPeriod = "30s";
    };

    unitConfig = {
      After = [ "romm-db.service" ];
      Requires = [ "romm-db.service" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/romm/resources 0755 root root -"
    "d /var/lib/romm/redis-data 0755 root root -"
    "d /var/lib/romm/assets 0755 root root -"
    "d /var/lib/romm/config 0755 root root -"
    "C /var/lib/romm/config/config.yml 0644 root root - ${rommConfig}"
    "d /var/lib/romm/mariadb 0750 999 999 -"
  ];

  services.restic.backups.apps = {
    paths = [
      "/var/lib/romm/assets"
      "/var/lib/romm/config"
    ];
  };
}
