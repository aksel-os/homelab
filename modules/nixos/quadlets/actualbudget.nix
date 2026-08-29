{ config, ... }:

{
  virtualisation.quadlet.containers.actual = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.actual.rule=Host(`actual.internal.akselos.no`)"
        "traefik.http.routers.actual.entrypoints=websecure"
        "traefik.http.routers.actual.tls=true"
        "traefik.http.routers.actual.tls.certresolver=letsencrypt"
        "traefik.http.services.actual.loadbalancer.server.port=5006"
      ];

      image = "ghcr.io/actualbudget/actual-server:latest";

      environments = {
        TZ = config.time.timeZone;
      };
      volumes = [
        "/var/lib/actualbudget/data:/data"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/actualbudget/data 0755 1000 1000 -"
  ];

  services.restic.backups.apps = {
    paths = [ "/var/lib/actualbudget/data:/data" ];
  };
}
