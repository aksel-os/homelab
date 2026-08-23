{ config, ... }:

let
  inherit (config.virtualisation.quadlet) networks;

in
{
  # Port: 5299
  virtualisation.quadlet.containers.lazylibrarian = {
    containerConfig = {
      image = "docker.io/linuxserver/lazylibrarian:latest";
      networks = [ networks.arr.ref ];

      environments = {
        TZ = config.time.timeZone;
        PUID = "1000";
        PGID = "1000";
      };

      volumes = [
        "/var/lib/lazylibrarian/config:/config"
        "/mnt/nas/media/books:/books"
        "/data/torrents:/data/torrents"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/lazylibrarian/config 0755 1000 1000 -"
  ];
}
