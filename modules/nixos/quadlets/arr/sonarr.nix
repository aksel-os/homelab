{ config, ... }:

let
  inherit (config.virtualisation.quadlet) networks;

in
{
  virtualisation.quadlet.containers.sonarr = {
    containerConfig = {
      name = "sonarr";
      image = "docker.io/linuxserver/sonarr:latest";
      networks = [ networks.arr.ref ];
      publishPorts = [ "8989:8989" ];

      environments = {
        TZ = "Europe/Oslo";
        PUID = "1000";
        PGID = "1000";
      };

      volumes = [
        "/var/lib/sonarr/config:/config"
        "/data/torrents:/data/torrents"
      ];
    };

    unitConfig = {
      After = [ "qbittorrent.service" ];
      Wants = [ "qbittorrent.service" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/sonarr/config 0755 1000 1000 -"
  ];
}
