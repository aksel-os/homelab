{ config, ... }:

let
  inherit (config.virtualisation.quadlet) networks;

in
{
  virtualisation.quadlet.containers.sonarr = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.sonarr.rule=Host(`sonarr.internal.akselos.no`)"
        "traefik.http.routers.sonarr.entrypoints=websecure"
        "traefik.http.routers.sonarr.tls=true"
        "traefik.http.routers.sonarr.tls.certresolver=letsencrypt"
        "traefik.http.services.sonarr.loadbalancer.server.port=8989"
        "traefik.http.routers.sonarr.middlewares=purescale@file"
      ];

      image = "docker.io/linuxserver/sonarr:latest";
      networks = [ networks.arr.ref ];

      environments = {
        TZ = config.time.timeZone;
        PUID = "1000";
        PGID = "1000";
      };

      volumes = [
        "/var/lib/sonarr/config:/config"
        "/mnt/nas/media/series:/tv"
        "/data/torrents:/data/torrents"
      ];
    };

    unitConfig = {
      After = [ "qbittorrent.service" ];
      Wants = [ "qbittorrent.service" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/sonarr/config 0755 1000 1000 -"
  ];
}
