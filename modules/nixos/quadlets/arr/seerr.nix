{ config, ... }:

let
  inherit (config.virtualisation.quadlet) networks;

in
{
  virtualisation.quadlet.containers.seerr = {
    containerConfig = {
      image = "ghcr.io/seerr-team/seerr:latest";
      networks = [ networks.arr.ref ];

      publishPorts = [ "5055:5055" ];

      environments = {
        TZ = "Europe/Oslo";
        LOG_LEVEL = "info";
      };

      volumes = [
        "/var/lib/seerr/config:/app/config"
      ];

      healthCmd = "wget --no-verbose --tries=1 --spider http://localhost:5055/api/v1/status || exit 1";
      healthInterval = "15s";
      healthTimeout = "3s";
      healthRetries = 3;
      healthStartPeriod = "20s";
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
    "d /var/lib/seerr/config 0755 1000 1000 -"
  ];
}
