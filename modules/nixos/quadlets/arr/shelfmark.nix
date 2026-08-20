{ config, ... }:

let
  inherit (config.virtualisation.quadlet) networks;

in
{
  virtualisation.quadlet.containers.shelfmark = {
    containerConfig = {
      image = "ghcr.io/calibrain/shelfmark:latest";
      networks = [ networks.arr.ref ];
      publishPorts = [ "8084:8084" ];

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
      After = [ "qbittorrent.service" ];
      Wants = [ "qbittorrent.service" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/shelfmark/config 0755 1000 1000 -"
  ];
}
