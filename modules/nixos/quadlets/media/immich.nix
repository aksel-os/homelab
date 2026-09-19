{ config, self, ... }:

let
  inherit (config.sops) templates;
  inherit (config.virtualisation.quadlet) networks;

in
{
  sops.secrets = {
    "immich/postgres_password" = {
      sopsFile = "${self}/secrets/services/immich.yaml";
    };
  };

  sops.templates."immich-postgres.env" = {
    content = ''
      POSTGRES_PASSWORD=${config.sops.placeholder."immich/postgres_password"}
    '';
    restartUnits = [ "immich-postgres.service" ];
  };

  sops.templates."immich.env" = {
    content = ''
      DB_PASSWORD=${config.sops.placeholder."immich/postgres_password"}
    '';
    restartUnits = [ "immich.service" ];
  };

  virtualisation.quadlet.containers.immich-postgres = {
    containerConfig = {
      image = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0";
      networks = [ networks.dns.ref ];

      environments = {
        POSTGRES_USER = "immich";
        POSTGRES_DB = "immich";
        POSTGRES_INITDB_ARGS = "--data-checksums";
      };

      environmentFiles = [ templates."immich-postgres.env".path ];

      volumes = [ "/var/lib/immich/postgres:/var/lib/postgresql/data" ];
    };
  };

  virtualisation.quadlet.containers.immich-redis = {
    containerConfig = {
      image = "docker.io/valkey/valkey:9";
      networks = [ networks.dns.ref ];
      volumes = [ "/var/lib/immich/redis:/data" ];
    };
  };

  virtualisation.quadlet.containers.immich-machine-learning = {
    containerConfig = {
      image = "ghcr.io/immich-app/immich-machine-learning:release";
      networks = [ networks.dns.ref ];

      volumes = [
        "/var/lib/immich/model-cache:/cache"
      ];
    };
  };

  virtualisation.quadlet.containers.immich = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.immich.rule=Host(`immich.internal.akselos.no`)"
        "traefik.http.routers.immich.entrypoints=websecure"
        "traefik.http.routers.immich.tls=true"
        "traefik.http.routers.immich.tls.certresolver=letsencrypt"
        "traefik.http.services.immich.loadbalancer.server.port=2283"
        "traefik.http.routers.immich.middlewares=purescale@file"
      ];

      image = "ghcr.io/immich-app/immich-server:release";
      networks = [ networks.dns.ref ];

      environments = {
        TZ = config.time.timeZone;
        HOST = "0.0.0.0";
        DB_HOSTNAME = "immich-postgres";
        DB_USERNAME = "immich";
        DB_DATABASE_NAME = "immich";
        REDIS_HOSTNAME = "immich-redis";
        IMMICH_MACHINE_LEARNING_URL = "http://immich-machine-learning:3003";
      };

      environmentFiles = [ templates."immich.env".path ];

      volumes = [
        "/mnt/photos:/data"
        "/etc/localtime:/etc/localtime:ro"
      ];
    };

    unitConfig = {
      After = [
        "immich-postgres.service"
        "immich-redis.service"
        "immich-machine-learning.service"
      ];
      Requires = [
        "immich-postgres.service"
        "immich-redis.service"
        "immich-machine-learning.service"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/immich/postgres 0750 999 999 -"
    "d /var/lib/immich/redis 0755 999 999 -"
    "d /var/lib/immich/model-cache 0755 1000 1000 -"
  ];
}
