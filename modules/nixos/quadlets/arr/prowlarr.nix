{ config, ... }:

let
  inherit (config.virtualisation.quadlet) networks;

in
{
  virtualisation.quadlet.containers.prowlarr = {
    containerConfig = {
      image = "docker.io/linuxserver/prowlarr:latest";
      networks = [ networks.arr.ref ];
      publishPorts = [ "9696:9696" ];

      environments = {
        TZ = "Europe/Oslo";
        PUID = "1000";
        PGID = "1000";
      };

      volumes = [
        "/var/lib/prowlarr/config:/config"
        "/data/torrents:/data/torrents"
      ];
    };

    unitConfig = {
      After = [
        "sonarr.service"
        "radarr.service"
      ];
      Wants = [
        "sonarr.service"
        "radarr.service"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/prowlarr/config 0755 1000 1000 -"
  ];
}
