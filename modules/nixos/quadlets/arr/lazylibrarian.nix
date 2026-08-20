{ config, ... }:

let
  inherit (config.virtualisation.quadlet) networks;

in
{
  virtualisation.quadlet.containers.lazylibrarian = {
    containerConfig = {
      image = "docker.io/linuxserver/lazylibrarian:latest";
      networks = [ networks.arr.ref ];
      publishPorts = [ "5299:5299" ];

      environments = {
        TZ = "Europe/Oslo";
        PUID = "1000";
        PGID = "1000";
      };

      volumes = [
        "/var/lib/lazylibrarian/config:/config"
        "/data/torrents:/data/torrents"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/lazylibrarian/config 0755 1000 1000 -"
  ];
}
