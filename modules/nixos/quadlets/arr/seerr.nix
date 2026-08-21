{ config, ... }:

let
  inherit (config.virtualisation.quadlet) networks;

in
{
  virtualisation.quadlet.containers.seerr = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.seerr.rule=Host(`seerr.internal.akselos.no`)"
        "traefik.http.routers.seerr.entrypoints=websecure"
        "traefik.http.routers.seerr.tls=true"
        "traefik.http.routers.seerr.tls.certresolver=letsencrypt"
        "traefik.http.services.seerr.loadbalancer.server.port=5055"
      ];

      image = "ghcr.io/seerr-team/seerr:latest";
      networks = [
        networks.arr.ref
        networks.dns.ref
      ];

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
