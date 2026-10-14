{ config, self, ... }:

let
  inherit (config.sops) templates;
  inherit (config.virtualisation.quadlet) networks;

in
{
  sops.secrets."searxng/secret_key".sopsFile = "${self}/secrets/services/searxng.yaml";

  sops.templates."searxng.env" = {
    content = ''
      SEARXNG_SECRET=${config.sops.placeholder."searxng/secret_key"}
    '';
    restartUnits = [ "searxng.service" ];
  };

  virtualisation.quadlet.containers.searxng = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.searxng.rule=Host(`searxng.internal.akselos.no`)"
        "traefik.http.routers.searxng.entrypoints=websecure"
        "traefik.http.routers.searxng.tls=true"
        "traefik.http.routers.searxng.tls.certresolver=letsencrypt"
        "traefik.http.services.searxng.loadbalancer.server.port=8080"
        "traefik.http.routers.searxng.middlewares=purescale@file"
      ];

      image = "docker.io/searxng/searxng:latest";
      networks = [ networks.dns.ref ];

      environmentFiles = [ templates."searxng.env".path ];
      environments = {
        TZ = config.time.timeZone;
        SEARXNG_BASE_URL = "https://searxng.internal.akselos.no/";
      };

      volumes = [
        "/var/lib/searxng/config:/etc/searxng"
        "/var/lib/searxng/data:/var/cache/searxng"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/searxng/config 0755 977 977 -"
    "d /var/lib/searxng/data 0755 977 977 -"
  ];

  services.restic.backups.apps = {
    paths = [ "/var/lib/searxng/config" ];
  };
}
