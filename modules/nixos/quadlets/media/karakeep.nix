{ config, self, ... }:

let
  inherit (config.sops) templates;
  inherit (config.virtualisation.quadlet) networks;

in
{
  sops.secrets = {
    "karakeep/nextauth_secret".sopsFile = "${self}/secrets/services/karakeep.yaml";
    "karakeep/meili_master_key".sopsFile = "${self}/secrets/services/karakeep.yaml";
    # "karakeep/openai_api_key".sopsFile = "${self}/secrets/services/karakeep.yaml";
  };

  sops.templates."karakeep.env" = {
    content = ''
      NEXTAUTH_SECRET=${config.sops.placeholder."karakeep/nextauth_secret"}
      MEILI_MASTER_KEY=${config.sops.placeholder."karakeep/meili_master_key"}
    '';
    restartUnits = [ "karakeep.service" ];
  };

  sops.templates."karakeep-meilisearch.env" = {
    content = ''
      MEILI_MASTER_KEY=${config.sops.placeholder."karakeep/meili_master_key"}
    '';
    restartUnits = [ "karakeep-meilisearch.service" ];
  };

  virtualisation.quadlet.containers.karakeep = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.karakeep.rule=Host(`karakeep.internal.akselos.no`)"
        "traefik.http.routers.karakeep.entrypoints=websecure"
        "traefik.http.routers.karakeep.tls=true"
        "traefik.http.routers.karakeep.tls.certresolver=letsencrypt"
        "traefik.http.services.karakeep.loadbalancer.server.port=3000"
        "traefik.http.routers.karakeep.middlewares=purescale@file"
      ];

      image = "ghcr.io/karakeep-app/karakeep:release";
      networks = [ networks.dns.ref ];

      environmentFiles = [ templates."karakeep.env".path ];
      environments = {
        TZ = config.time.timeZone;
        DATA_DIR = "/data";
        NEXTAUTH_URL = "https://karakeep.internal.akselos.no";
        BROWSER_WEB_URL = "http://karakeep-chrome:9222";
        MEILI_ADDR = "http://karakeep-meilisearch:7700";
        DISABLE_SIGNUPS = "true";
      };

      volumes = [
        "/var/lib/karakeep/data:/data"
      ];
    };

    unitConfig = {
      After = [
        "karakeep-chrome.service"
        "karakeep-meilisearch.service"
      ];
      Requires = [
        "karakeep-chrome.service"
        "karakeep-meilisearch.service"
      ];
    };
  };

  virtualisation.quadlet.containers.karakeep-meilisearch = {
    containerConfig = {
      image = "docker.io/getmeili/meilisearch:v1.41.0";
      networks = [ networks.dns.ref ];

      environmentFiles = [ templates."karakeep-meilisearch.env".path ];
      environments = {
        MEILI_NO_ANALYTICS = "true";
      };

      volumes = [
        "/var/lib/karakeep/meilisearch:/meili_data"
      ];
    };
  };

  virtualisation.quadlet.containers.karakeep-chrome = {
    containerConfig = {
      image = "ghcr.io/karakeep-app/karakeep-chrome:release";
      networks = [ networks.dns.ref ];

      exec = [
        "--disable-gpu"
        "--disable-dev-shm-usage"
        "--hide-scrollbars"
        "--disable-blink-features=AutomationControlled"
        "--window-size=1440,900"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/karakeep/data 0755 1000 1000 -"
    "d /var/lib/karakeep/meilisearch 0755 root root -"
  ];

  services.restic.backups.apps = {
    paths = [
      "/var/lib/karakeep/data"
      "/var/lib/karakeep/meilisearch"
    ];
  };
}
