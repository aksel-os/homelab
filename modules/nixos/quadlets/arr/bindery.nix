{ config, ... }:

let
  inherit (config.virtualisation.quadlet) networks;

in
{
  virtualisation.quadlet.containers.bindery = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.bindery.rule=Host(`bindery.internal.akselos.no`)"
        "traefik.http.routers.bindery.entrypoints=websecure"
        "traefik.http.routers.bindery.tls=true"
        "traefik.http.routers.bindery.tls.certresolver=letsencrypt"
        "traefik.http.services.bindery.loadbalancer.server.port=8787"
        "traefik.http.routers.bindery.middlewares=purescale@file"
      ];

      image = "ghcr.io/vavallee/bindery:v1.33.2";
      networks = [
        networks.arr.ref
        networks.dns.ref
      ];

      user = "1000:1000";
      environments = {
        TZ = config.time.timeZone;
        BINDERY_PUID = "1000";
        BINDERY_PGID = "1000";
        BINDERY_DOWNLOAD_DIR = "/data";
        BINDERY_LIBRARY_DIR = "/data/media/books";
        BINDERY_AUDIOBOOK_DIR = "/data/media/audiobooks";
        BINDERY_TELEMETRY_DISABLED = "true";
      };

      volumes = [
        "/var/lib/bindery/config:/config"
        "/mnt/nas:/data"
      ];
    };

    unitConfig = {
      After = [ "qbittorrent.service" ];
      Wants = [ "qbittorrent.service" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/bindery/config 0755 1000 1000 -"
  ];

  services.restic.backups.apps = {
    paths = [ "/var/lib/bindery/config" ];
  };
}
