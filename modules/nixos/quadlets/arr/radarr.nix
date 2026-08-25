{ config, self, ... }:

let
  inherit (config.virtualisation.quadlet) networks;
  inherit (config.sops) templates;

in
{
  sops.secrets."radarr/api_key".sopsFile = "${self}/secrets/services/radarr.yaml";

  sops.templates."radarr.env" = {
    content = ''
      RADARR__AUTH__APIKEY=${config.sops.placeholder."radarr/api_key"}
    '';
    restartUnits = [ "radarr.service" ];
  };

  virtualisation.quadlet.containers.radarr = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.radarr.rule=Host(`radarr.internal.akselos.no`)"
        "traefik.http.routers.radarr.entrypoints=websecure"
        "traefik.http.routers.radarr.tls=true"
        "traefik.http.routers.radarr.tls.certresolver=letsencrypt"
        "traefik.http.services.radarr.loadbalancer.server.port=7878"
        "traefik.http.routers.radarr.middlewares=purescale@file"
      ];

      image = "docker.io/linuxserver/radarr:latest";
      networks = [ networks.arr.ref ];
      publishPorts = [ "127.0.0.1:7878:7878" ];

      environments = {
        TZ = config.time.timeZone;
        PUID = "1000";
        PGID = "1000";
      };

      environmentFiles = [ templates."radarr.env".path ];

      volumes = [
        "/var/lib/radarr/config:/config"
        "/mnt/nas:/data"
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
