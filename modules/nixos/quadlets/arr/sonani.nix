{ config, self, ... }:

let
  inherit (config.virtualisation.quadlet) networks;
  inherit (config.sops) templates;

in
{
  sops.secrets."sonani/api_key".sopsFile = "${self}/secrets/services/sonarr.yaml";

  sops.templates."sonani.env" = {
    content = ''
      SONARR__AUTH__APIKEY=${config.sops.placeholder."sonani/api_key"}
    '';
    restartUnits = [ "sonani.service" ];
  };

  virtualisation.quadlet.containers.sonani = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.sonani.rule=Host(`sonani.internal.akselos.no`)"
        "traefik.http.routers.sonani.entrypoints=websecure"
        "traefik.http.routers.sonani.tls=true"
        "traefik.http.routers.sonani.tls.certresolver=letsencrypt"
        "traefik.http.services.sonani.loadbalancer.server.port=9898"
        "traefik.http.routers.sonani.middlewares=purescale@file"
      ];

      image = "docker.io/linuxserver/sonarr:latest";
      networks = [ networks.arr.ref ];
      publishPorts = [ "127.0.0.1:9898:9898" ];

      environments = {
        TZ = config.time.timeZone;
        PUID = "1000";
        PGID = "1000";
        SONARR__SERVER__PORT = "9898";
      };

      environmentFiles = [ templates."sonani.env".path ];

      volumes = [
        "/var/lib/sonani/config:/config"
        "/mnt/nas:/data"
      ];
    };

    unitConfig = {
      After = [ "qbittorrent.service" ];
      Wants = [ "qbittorrent.service" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/sonani/config 0755 1000 1000 -"
  ];

  services.restic.backups.apps = {
    paths = [ "/var/lib/sonani/config" ];
  };
}
