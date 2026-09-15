{ config, self, ... }:

let
  inherit (config.sops) templates;
  inherit (config.virtualisation.quadlet) networks;

in
{
  sops.secrets = {
    "sparkyfitness/db_password".sopsFile = "${self}/secrets/services/sparkyfitness.yaml";
    "sparkyfitness/app_db_password".sopsFile = "${self}/secrets/services/sparkyfitness.yaml";
    "sparkyfitness/api_encryption_key".sopsFile = "${self}/secrets/services/sparkyfitness.yaml";
    "sparkyfitness/better_auth_secret".sopsFile = "${self}/secrets/services/sparkyfitness.yaml";
  };

  sops.templates."sparkyfitness-db.env" = {
    content = ''
      POSTGRES_PASSWORD=${config.sops.placeholder."sparkyfitness/db_password"}
    '';
    restartUnits = [ "sparkyfitness-db.service" ];
  };

  sops.templates."sparkyfitness-server.env" = {
    content = ''
      SPARKY_FITNESS_DB_PASSWORD=${config.sops.placeholder."sparkyfitness/db_password"}
      SPARKY_FITNESS_APP_DB_PASSWORD=${config.sops.placeholder."sparkyfitness/app_db_password"}
      SPARKY_FITNESS_API_ENCRYPTION_KEY=${config.sops.placeholder."sparkyfitness/api_encryption_key"}
      BETTER_AUTH_SECRET=${config.sops.placeholder."sparkyfitness/better_auth_secret"}
    '';
    restartUnits = [ "sparkyfitness-server.service" ];
  };

  virtualisation.quadlet.containers.sparkyfitness-db = {
    containerConfig = {
      image = "docker.io/postgres:18.3-alpine";
      networks = [ networks.dns.ref ];

      environmentFiles = [ templates."sparkyfitness-db.env".path ];
      environments = {
        POSTGRES_DB = "sparkyfitness_db";
        POSTGRES_USER = "sparky";
        PUID = "1000";
        GUID = "1000";
      };

      volumes = [
        "/var/lib/sparkyfitness/postgres:/var/lib/postgresql"
      ];

      healthCmd = "pg_isready -U sparky -d sparkyfitness_db";
      healthInterval = "10s";
      healthTimeout = "5s";
      healthRetries = 10;
      healthStartPeriod = "20s";
    };
  };

  virtualisation.quadlet.containers.sparkyfitness-server = {
    containerConfig = {
      image = "docker.io/codewithcj/sparkyfitness_server:v1.7.1";
      networks = [ networks.dns.ref ];

      environmentFiles = [ templates."sparkyfitness-server.env".path ];
      environments = {
        SPARKY_FITNESS_DB_HOST = "sparkyfitness-db";
        SPARKY_FITNESS_DB_PORT = "5432";
        SPARKY_FITNESS_DB_NAME = "sparkyfitness_db";
        SPARKY_FITNESS_DB_USER = "sparky";
        SPARKY_FITNESS_APP_DB_USER = "sparky_app";
        SPARKY_FITNESS_FRONTEND_URL = "https://sparky.internal.akselos.no";
        NODE_ENV = "production";
        TZ = config.time.timeZone;
        SPARKY_FITNESS_LOG_LEVEL = "ERROR";
        SPARKY_FITNESS_PUBLIC_API_DOCS = "false";
        SPARKY_FITNESS_DISABLE_SIGNUP = "false";
        SPARKY_FITNESS_DEMO_MODE = "false";
        SPARKY_FITNESS_TRUSTED_PROXY_HOPS = "2"; # Traefik + frontend's own nginx
        PUID = "1000";
        GUID = "1000";
      };

      volumes = [
        "/var/lib/sparkyfitness/backup:/app/SparkyFitnessServer/backup"
        "/var/lib/sparkyfitness/uploads:/app/SparkyFitnessServer/uploads"
      ];
    };

    unitConfig = {
      After = [ "sparkyfitness-db.service" ];
      Requires = [ "sparkyfitness-db.service" ];
    };
  };

  virtualisation.quadlet.containers.sparkyfitness-frontend = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.sparkyfitness.rule=Host(`sparky.internal.akselos.no`)"
        "traefik.http.routers.sparkyfitness.entrypoints=websecure"
        "traefik.http.routers.sparkyfitness.tls=true"
        "traefik.http.routers.sparkyfitness.tls.certresolver=letsencrypt"
        "traefik.http.services.sparkyfitness.loadbalancer.server.port=80"
        "traefik.http.routers.sparkyfitness.middlewares=purescale@file"
      ];

      image = "docker.io/codewithcj/sparkyfitness:v1.7.1";
      networks = [ networks.dns.ref ];

      environments = {
        SPARKY_FITNESS_FRONTEND_URL = "https://sparky.internal.akselos.no";
        SPARKY_FITNESS_SERVER_HOST = "sparkyfitness-server";
        SPARKY_FITNESS_SERVER_PORT = "3010";
        NGINX_RATE_LIMIT = "5r/s";
        PUID = "1000";
        GUID = "1000";
      };
    };

    unitConfig = {
      After = [ "sparkyfitness-server.service" ];
      Wants = [ "sparkyfitness-server.service" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/sparkyfitness/postgres 0750 70 70 -" # postgres:postgres
    "d /var/lib/sparkyfitness/backup 0755 1000 1000 -"
    "d /var/lib/sparkyfitness/uploads 0755 1000 1000 -"
  ];

  services.restic.backups.apps = {
    paths = [
      "/var/lib/sparkyfitness/backup"
      "/var/lib/sparkyfitness/uploads"
    ];
  };
}
