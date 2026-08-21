{ config, ... }:

let
  inherit (config.virtualisation.quadlet) networks;

in
{
  virtualisation.quadlet.containers.radarr = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.radarr.rule=Host(`radarr.internal.akselos.no`)"
        "traefik.http.routers.radarr.entrypoints=websecure"
        "traefik.http.routers.radarr.tls=true"
        "traefik.http.routers.radarr.tls.certresolver=letsencrypt"
        "traefik.http.services.radarr.loadbalancer.server.port=7878"
      ];

      image = "docker.io/linuxserver/radarr:latest";
      networks = [ networks.arr.ref ];
      publishPorts = [ "7878:7878" ];

      environments = {
        TZ = "Europe/Oslo";
        PUID = "1000";
        PGID = "1000";
      };

      volumes = [
        "/var/lib/radarr/config:/config"
        "/mnt/nas/media/movies:/movies"
        "/data/torrents:/data/torrents"
      ];
    };

    unitConfig = {
      After = [ "qbittorrent.service" ];
      Wants = [ "qbittorrent.service" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/radarr/config 0755 1000 1000 -"
  ];
}
