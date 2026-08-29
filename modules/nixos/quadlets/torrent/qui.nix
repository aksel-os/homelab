{ config, ... }:
let
  inherit (config.virtualisation.quadlet) networks;

in
{
  virtualisation.quadlet.containers.qui = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.qui.rule=Host(`qui.internal.akselos.no`)"
        "traefik.http.routers.qui.entrypoints=websecure"
        "traefik.http.routers.qui.tls=true"
        "traefik.http.routers.qui.tls.certresolver=letsencrypt"
        "traefik.http.services.qui.loadbalancer.server.port=7476"
        "traefik.http.routers.qui.middlewares=purescale@file"
      ];

      image = "ghcr.io/autobrr/qui:latest";
      networks = [ networks.arr.ref ];

      environments = {
        TZ = config.time.timeZone;
      };
      volumes = [
        "/var/lib/qui/config:/config"
      ];
    };
    unitConfig = {
      After = [ "qbittorrent.service" ];
      Wants = [ "qbittorrent.service" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/qui/config 0755 1000 1000 -"
  ];
}
