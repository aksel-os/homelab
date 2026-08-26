{ config, ... }:

let
  inherit (config.virtualisation.quadlet) pods;

in
{
  virtualisation.quadlet.containers.shelfmark = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.shelfmark.rule=Host(`shelfmark.internal.akselos.no`)"
        "traefik.http.routers.shelfmark.entrypoints=websecure"
        "traefik.http.routers.shelfmark.tls=true"
        "traefik.http.routers.shelfmark.tls.certresolver=letsencrypt"
        "traefik.http.services.shelfmark.loadbalancer.server.port=8084"
        "traefik.http.routers.shelfmark.middlewares=purescale@file"
      ];

      image = "ghcr.io/calibrain/shelfmark:latest";

      pod = pods.torrent.ref;
      startWithPod = true;

      environments = {
        TZ = config.time.timeZone;
        PUID = "1000";
        PGID = "1000";
      };

      volumes = [
        "/var/lib/shelfmark/config:/config"
        "/mnt/nas:/data"
      ];
    };

    unitConfig = {
      After = [ "gluetun.service" ];
      Wants = [ "qbittorrent.service" ];
      Requires = [ "gluetun.service" ];
      BindsTo = [ "gluetun.service" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/shelfmark/config 0755 1000 1000 -"
  ];
}
