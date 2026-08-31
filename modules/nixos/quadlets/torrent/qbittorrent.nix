{ config, ... }:

let
  inherit (config.virtualisation.quadlet) pods;

in
{
  virtualisation.quadlet.containers.qbittorrent = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.qbit.rule=Host(`qbit.internal.akselos.no`)"
        "traefik.http.routers.qbit.entrypoints=websecure"
        "traefik.http.routers.qbit.tls=true"
        "traefik.http.routers.qbit.tls.certresolver=letsencrypt"
        "traefik.http.services.qbit.loadbalancer.server.port=8080"
        "traefik.http.routers.qbit.middlewares=purescale@file"
      ];

      image = "docker.io/linuxserver/qbittorrent:latest";

      pod = pods.torrent.ref;
      startWithPod = true;

      environments = {
        TZ = config.time.timeZone;
        WEBUI_PORT = "8080";
        PUID = "1000";
        PGID = "1000";
      };

      healthCmd = "curl -f http://localhost:8080/ || exit 1";
      healthInterval = "30s";
      healthTimeout = "10s";
      healthRetries = 3;
      healthStartPeriod = "30s";

      volumes = [
        "/var/lib/qbittorrent/config:/config"
        "/mnt/nas/torrents:/data/torrents"
      ];
    };

    unitConfig = {
      After = [ "gluetun.service" ];
      Requires = [ "gluetun.service" ];
      BindsTo = [ "gluetun.service" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/qbittorrent/config 0755 1000 1000 -"
  ];
}
