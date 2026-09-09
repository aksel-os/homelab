{ config, ... }:

let
  inherit (config.virtualisation.quadlet) pods;

in
{
  virtualisation.quadlet.containers.browser = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.browser.rule=Host(`browser.internal.akselos.no`)"
        "traefik.http.routers.browser.entrypoints=websecure"
        "traefik.http.routers.browser.tls=true"
        "traefik.http.routers.browser.tls.certresolver=letsencrypt"
        "traefik.http.services.browser.loadbalancer.server.port=3000"
        "traefik.http.routers.browser.middlewares=purescale@file"
      ];

      image = "docker.io/linuxserver/firefox:latest";

      pod = pods.torrent.ref;

      environments = {
        TZ = config.time.timeZone;
        PUID = "1000";
        PGID = "1000";
      };

      volumes = [
        "/var/lib/browser/config:/config"
      ];
    };

    unitConfig = {
      After = [ "gluetun.service" ];
      Requires = [ "gluetun.service" ];
      BindsTo = [ "gluetun.service" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/browser/config 0755 1000 1000 -"
  ];

  services.restic.backups.apps = {
    paths = [ "/var/lib/browser/config" ];
  };
}
