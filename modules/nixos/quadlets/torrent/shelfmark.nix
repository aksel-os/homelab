{ config, ... }:

let
  inherit (config.virtualisation.quadlet) pods;

in
{
  virtualisation.quadlet.containers.shelfmark = {
    containerConfig = {
      image = "ghcr.io/calibrain/shelfmark:latest";

      pod = pods.torrent.ref;
      startWithPod = true;

      environments = {
        TZ = "Europe/Oslo";
        PUID = "1000";
        PGID = "1000";
      };

      volumes = [
        "/var/lib/shelfmark/config:/config"
        "/mnt/nas/media/books:/books"
        "/data/torrents:/data/torrents"
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
