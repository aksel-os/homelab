{ config, self, ... }:
let
  inherit (config.virtualisation.quadlet) networks;

in
{
  sops.secrets = {
    "jellyfin/api_key" = {
      sopsFile = "${self}/secrets/services/jellyfin.yaml";
    };
  };

  virtualisation.quadlet.containers.jellyfin = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.jellyfin.rule=Host(`jellyfin.internal.akselos.no`)"
        "traefik.http.routers.jellyfin.entrypoints=websecure"
        "traefik.http.routers.jellyfin.tls=true"
        "traefik.http.routers.jellyfin.tls.certresolver=letsencrypt"
        "traefik.http.services.jellyfin.loadbalancer.server.port=8096"
      ];

      image = "ghcr.io/jellyfin/jellyfin:12.0-rc6";
      networks = [ networks.dns.ref ];
      volumes = [
        "/var/lib/jellyfin/config:/config"
        "/var/lib/jellyfin/cache:/cache"
        "/mnt/nas/media:/data/media"
      ];

      healthCmd = "curl -f http://localhost:8096/health || exit 1";
      healthInterval = "30s";
      healthTimeout = "10s";
      healthRetries = 3;
      healthStartPeriod = "60s";
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/jellyfin/config 0755 root root -"
    "d /var/lib/jellyfin/cache 0755 root root -"
  ];

  services.restic.backups.apps = {
    paths = [ "/var/lib/jellyfin/config" ];
    exclude = [ "/var/lib/jellyfin/cache" ];
  };
}
