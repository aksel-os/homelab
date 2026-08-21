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
      ];

      image = "docker.io/linuxserver/sonarr:latest";
      networks = [ networks.arr.ref ];
      publishPorts = [ "8989:8989" ];

      environments = {
        TZ = "Europe/Oslo";
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
