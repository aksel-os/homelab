{ config, ... }:

let
  inherit (config.virtualisation.quadlet) networks;

in
{
  virtualisation.quadlet.containers.autobrr = {
    containerConfig = {
      # labels = [
      #   "traefik.enable=true"
      #   "traefik.http.routers.autobrr.rule=Host(`autobrr.internal.akselos.no`)"
      #   "traefik.http.routers.autobrr.entrypoints=websecure"
      #   "traefik.http.routers.autobrr.tls=true"
      #   "traefik.http.routers.autobrr.tls.certresolver=letsencrypt"
      #   "traefik.http.services.autobrr.loadbalancer.server.port=7474"
      #   "traefik.http.routers.autobrr.middlewares=purescale@file"
      # ];

      image = "ghcr.io/autobrr/autobrr:latest";
      networks = [ networks.arr.ref ];
      publishPorts = [ "100.101.183.74:7474:7474" ];

      environments = {
        TZ = config.time.timeZone;
      };

      volumes = [
        "/var/lib/autobrr/config:/config"
      ];
    };

    unitConfig = {
      After = [ "qbittorrent.service" ];
      Wants = [
        "qbittorrent.service"
        "prowlarr.service"
        "sonarr.service"
        "sonani.service"
        "radarr.service"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/autobrr/config 0755 1000 1000 -"
  ];

  services.restic.backups.apps = {
    paths = [ "/var/lib/autobrr/config" ];
  };
}
