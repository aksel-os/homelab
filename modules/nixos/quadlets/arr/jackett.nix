{ config, ... }:

let
  inherit (config.virtualisation.quadlet) networks;

in
{
  virtualisation.quadlet.containers.jackett = {
    containerConfig = {
      image = "docker.io/linuxserver/jackett:latest";
      networks = [ networks.arr.ref ];

      publishPorts = [ "100.99.136.0:9117:9117" ];

      environments = {
        TZ = config.time.timeZone;
        PUID = "1000";
        PGID = "1000";
        AUTO_UPDATE = "true";
      };

      volumes = [
        "/var/lib/jackett/config:/config"
      ];

      healthCmd = "curl -f http://localhost:9117/UI/Dashboard || exit 1";
      healthInterval = "30s";
      healthTimeout = "10s";
      healthRetries = 3;
      healthStartPeriod = "30s";
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/jackett/config 0755 1000 1000 -"
  ];

  services.restic.backups.apps = {
    paths = [ "/var/lib/jackett/config" ];
  };
}
