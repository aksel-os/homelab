{ config, ... }:

let
  inherit (config.virtualisation.quadlet) networks;

in
{
  virtualisation.quadlet.containers.prowlarr = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.prowlarr.rule=Host(`prowlarr.internal.akselos.no`)"
        "traefik.http.routers.prowlarr.entrypoints=websecure"
        "traefik.http.routers.prowlarr.tls=true"
        "traefik.http.routers.prowlarr.tls.certresolver=letsencrypt"
        "traefik.http.services.prowlarr.loadbalancer.server.port=9696"
        "traefik.http.routers.prowlarr.middlewares=purescale@file"
      ];

      image = "docker.io/linuxserver/prowlarr:latest";
      networks = [ networks.arr.ref ];

      environments = {
        TZ = config.time.timeZone;
        PUID = "1000";
        PGID = "1000";
      };

      volumes = [
        "/var/lib/prowlarr/config:/config"
        "/mnt/nas:/data"
      ];
    };

    unitConfig = {
      After = [
        "sonarr.service"
        "radarr.service"
      ];
      Wants = [
        "sonarr.service"
        "radarr.service"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/prowlarr/config 0755 1000 1000 -"
  ];
}
