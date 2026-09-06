{ config, ... }:

let
  inherit (config.virtualisation.quadlet) networks;

in
{
  virtualisation.quadlet.containers.cleanuparr = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.cleanuparr.rule=Host(`cleanuparr.internal.akselos.no`)"
        "traefik.http.routers.cleanuparr.entrypoints=websecure"
        "traefik.http.routers.cleanuparr.tls=true"
        "traefik.http.routers.cleanuparr.tls.certresolver=letsencrypt"
        "traefik.http.services.cleanuparr.loadbalancer.server.port=11011"
        "traefik.http.routers.cleanuparr.middlewares=purescale@file"
      ];

      image = "ghcr.io/cleanuparr/cleanuparr:latest";
      networks = [ networks.arr.ref ];

      environments = {
        TZ = config.time.timeZone;
        PORT = "11011";
        PUID = "1000";
        PGID = "1000";
      };

      volumes = [
        "/var/lib/cleanuparr/config:/config"
      ];
    };

    unitConfig = {
      After = [ "qbittorrent.service" ];
      Wants = [
        "qbittorrent.service"
        "sonarr.service"
        "sonani.service"
        "radarr.service"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/cleanuparr/config 0755 1000 1000 -"
  ];

  services.restic.backups.apps = {
    paths = [ "/var/lib/cleanuparr/config" ];
  };
}
