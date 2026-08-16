{ config, ... }:

let
  inherit (config.virtualisation.quadlet) pods;

in
{
  virtualisation.quadlet.containers.qbittorrent = {
    containerConfig = {
      image = "docker.io/linuxserver/qbittorrent:latest";

      pod = pods.torrent.ref;
      startWithPod = true;

      environments = {
        TZ = "Europe/Oslo";
        WEBUI_PORT = "8080";
        PUID = "1000";
        PGID = "1000";
      };

      volumes = [
        "/var/lib/qbittorrent/config:/config"
        "/data/torrents:/data/torrents"
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
    "d /data/torrents 0755 1000 1000 -"
  ];
}
