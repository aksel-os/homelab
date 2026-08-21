{ config, ... }:
let
  inherit (config.virtualisation.quadlet) networks;

in
{
  virtualisation.quadlet.containers.shoko = {
    containerConfig = {
      image = "ghcr.io/shokoanime/server:latest";
      networks = [ networks.dns.ref ];
      publishPorts = [ "8111:8111" ];

      environments = {
        TZ = "Europe/Oslo";
        PUID = "1000";
        PGID = "100";
      };
      volumes = [
        "/var/lib/shoko/config:/home/shoko/.shoko"
        "/mnt/nas/media/anime:/anime"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/shoko/config 0755 1000 100 -"
  ];
}
