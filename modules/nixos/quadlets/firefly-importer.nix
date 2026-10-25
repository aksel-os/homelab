{ config, ... }:

let
  inherit (config.sops) templates;
  inherit (config.virtualisation.quadlet) networks;

in
{
  virtualisation.quadlet.containers.firefly-importer = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.firefly-importer.rule=Host(`f3importer.internal.akselos.no`)"
        "traefik.http.routers.firefly-importer.entrypoints=websecure"
        "traefik.http.routers.firefly-importer.tls=true"
        "traefik.http.routers.firefly-importer.tls.certresolver=letsencrypt"
        "traefik.http.services.firefly-importer.loadbalancer.server.port=8080"
        "traefik.http.routers.firefly-importer.middlewares=purescale@file"
      ];

      image = "docker.io/fireflyiii/data-importer:version-2.3.5";
      networks = [ networks.dns.ref ];

      environmentFiles = [ templates."firefly-importer.env".path ];
      environments = {
        TZ = config.time.timeZone;
        FIREFLY_III_URL = "http://firefly:8080";
        VANITY_URL = "https://firefly.internal.akselos.no";
        FIREFLY_III_CLIENT_ID = "01a17543-647d-73eb-9239-9e73c25f6063";
        TRUSTED_PROXIES = "**";
      };
    };

    unitConfig = {
      After = [ "firefly.service" ];
      Wants = [ "firefly.service" ];
    };
  };
}
