{ config, self, ... }:

let
  inherit (config.sops) templates;
  inherit (config.virtualisation.quadlet) networks;

in
{
  sops.secrets."komf/komga_password".sopsFile = "${self}/secrets/services/komf.yaml";

  sops.templates."komf.env" = {
    content = ''
      KOMF_KOMGA_PASSWORD=${config.sops.placeholder."komf/komga_password"}
    '';
    restartUnits = [ "komf.service" ];
  };

  virtualisation.quadlet.containers.komf = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.komf.rule=Host(`komf.internal.akselos.no`)"
        "traefik.http.routers.komf.entrypoints=websecure"
        "traefik.http.routers.komf.tls=true"
        "traefik.http.routers.komf.tls.certresolver=letsencrypt"
        "traefik.http.services.komf.loadbalancer.server.port=8085"
        "traefik.http.routers.komf.middlewares=purescale@file"
      ];

      image = "docker.io/sndxr/komf:2.1.0";
      networks = [ networks.dns.ref ];

      user = "1000:1000";
      noNewPrivileges = true;
      dropCapabilities = [ "ALL" ];

      environmentFiles = [ templates."komf.env".path ];
      environments = {
        TZ = config.time.timeZone;
        KOMF_LOG_LEVEL = "INFO";
        KOMF_KOMGA_BASE_URI = "http://komga:25600";
        KOMF_KOMGA_USER = "komga@akselos.no";
      };

      volumes = [
        "/var/lib/komf/config:/config"
      ];
    };

    unitConfig = {
      After = [ "komga.service" ];
      Wants = [ "komga.service" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/komf/config 0755 1000 1000 -"
  ];

  services.restic.backups.apps = {
    paths = [ "/var/lib/komf/config" ];
  };
}
