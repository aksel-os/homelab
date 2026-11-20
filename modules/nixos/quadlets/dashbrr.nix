{ config, ... }:
let
  inherit (config.virtualisation.quadlet) networks;
in
{
  virtualisation.quadlet.containers.dashbrr = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.dashbrr.rule=Host(`dashbrr.internal.akselos.no`)"
        "traefik.http.routers.dashbrr.entrypoints=websecure"
        "traefik.http.routers.dashbrr.tls=true"
        "traefik.http.routers.dashbrr.tls.certresolver=letsencrypt"
        "traefik.http.services.dashbrr.loadbalancer.server.port=8080"
        "traefik.http.routers.dashbrr.middlewares=purescale@file"
      ];

      image = "ghcr.io/autobrr/dashbrr:v0.8.0";
      networks = [
        networks.arr.ref
        networks.dns.ref
      ];

      environments = {
        TZ = config.time.timeZone;
        DASHBRR__DB_TYPE = "sqlite";
        DASHBRR__DB_PATH = "/config/dashbrr.db";
        DASHBRR__LISTEN_ADDR = "0.0.0.0:8080";
      };

      volumes = [
        "/var/lib/dashbrr/config:/config"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/dashbrr/config 0755 1000 1000 -"
  ];

  services.restic.backups.apps.paths = [ "/var/lib/dashbrr/config" ];
}
