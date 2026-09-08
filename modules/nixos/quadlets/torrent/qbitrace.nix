{ config, ... }:

let
  inherit (config.virtualisation.quadlet) pods;

in
{
  virtualisation.quadlet.containers.qbitrace = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.qbitrace.rule=Host(`qrace.internal.akselos.no`)"
        "traefik.http.routers.qbitrace.entrypoints=websecure"
        "traefik.http.routers.qbitrace.tls=true"
        "traefik.http.routers.qbitrace.tls.certresolver=letsencrypt"
        "traefik.http.services.qbitrace.loadbalancer.server.port=8081"
        "traefik.http.routers.qbitrace.middlewares=purescale@file"
      ];

      image = "docker.io/linuxserver/qbittorrent:latest";

      pod = pods.torrent.ref;
      startWithPod = true;

      environments = {
        TZ = config.time.timeZone;
        WEBUI_PORT = "8081";
        PUID = "1000";
        PGID = "1000";
      };

      healthCmd = "curl -f http://localhost:8081/ || exit 1";
      healthInterval = "30s";
      healthTimeout = "10s";
      healthRetries = 3;
      healthStartPeriod = "30s";

      volumes = [
        "/var/lib/qbitrace/config:/config"
        "/var/lib/qbitrace/downloads:/data/torrents"
      ];
    };

    unitConfig = {
      After = [ "gluetun.service" ];
      Requires = [ "gluetun.service" ];
      BindsTo = [ "gluetun.service" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/qbitrace/config 0755 1000 1000 -"
    "d /var/lib/qbitrace/downloads 0755 1000 1000 -"
  ];
}
