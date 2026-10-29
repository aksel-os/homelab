{ config, self, ... }:

let
  inherit (config.sops) templates;
  inherit (config.virtualisation.quadlet) networks;

in
{
  sops.secrets."degoog/settings_password".sopsFile = "${self}/secrets/services/degoog.yaml";

  sops.templates."degoog.env" = {
    content = ''
      DEGOOG_SETTINGS_PASSWORDS=${config.sops.placeholder."degoog/settings_password"}
    '';
    restartUnits = [ "degoog.service" ];
  };

  virtualisation.quadlet.containers.degoog = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.degoog.rule=Host(`degoog.internal.akselos.no`)"
        "traefik.http.routers.degoog.entrypoints=websecure"
        "traefik.http.routers.degoog.tls=true"
        "traefik.http.routers.degoog.tls.certresolver=letsencrypt"
        "traefik.http.services.degoog.loadbalancer.server.port=4444"
        "traefik.http.routers.degoog.middlewares=purescale@file"
      ];

      image = "ghcr.io/degoog-org/degoog:1.1.1";
      networks = [ networks.dns.ref ];

      environmentFiles = [ templates."degoog.env".path ];
      environments = {
        TZ = config.time.timeZone;
        DEGOOG_PUBLIC_INSTANCE = "false";
        DEGOOG_VALKEY_URL = "redis://degoog-valkey:6379";
      };

      volumes = [
        "/var/lib/degoog/data:/app/data"
      ];
    };

    unitConfig = {
      After = [ "degoog-valkey.service" ];
      Requires = [ "degoog-valkey.service" ];
    };
  };

  virtualisation.quadlet.containers.degoog-valkey = {
    containerConfig = {
      image = "docker.io/valkey/valkey:8-alpine";
      networks = [ networks.dns.ref ];

      exec = [
        "--save"
        ""
        "--appendonly"
        "no"
      ];

      user = "1000:1000";
      readOnly = true;
      noNewPrivileges = true;
      dropCapabilities = [ "ALL" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/degoog/data 0755 1000 1000 -"
  ];

  services.restic.backups.apps = {
    paths = [ "/var/lib/degoog/data" ];
  };
}
