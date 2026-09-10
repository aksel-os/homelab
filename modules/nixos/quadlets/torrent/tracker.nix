{ config, self, ... }:

let
  inherit (config.virtualisation.quadlet) pods;
  inherit (config.sops) templates;

in
{
  sops.secrets."mousehole/auth_password".sopsFile = "${self}/secrets/services/mousehole.yaml";

  sops.templates."mousehole.env" = {
    content = ''
      MOUSEHOLE_AUTH_PASSWORD=${config.sops.placeholder."mousehole/auth_password"}
    '';
    restartUnits = [ "mousehole.service" ];
  };

  virtualisation.quadlet.containers.mousehole = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.mousehole.rule=Host(`mousehole.internal.akselos.no`)"
        "traefik.http.routers.mousehole.entrypoints=websecure"
        "traefik.http.routers.mousehole.tls=true"
        "traefik.http.routers.mousehole.tls.certresolver=letsencrypt"
        "traefik.http.services.mousehole.loadbalancer.server.port=5010"
        "traefik.http.routers.mousehole.middlewares=purescale@file"
      ];

      image = "docker.io/tmmrtn/mousehole:latest";

      pod = pods.torrent.ref;
      startWithPod = true;

      environments = {
        TZ = config.time.timeZone;
        MOUSEHOLE_ALLOWED_HOSTS = "mousehole.internal.akselos.no";
        MOUSEHOLE_ALLOWED_ORIGINS = "https://mousehole.internal.akselos.no";
      };

      environmentFiles = [ templates."mousehole.env".path ];

      volumes = [
        "/var/lib/mousehole/data:/var/lib/mousehole"
      ];
    };

    unitConfig = {
      After = [ "gluetun.service" ];
      Requires = [ "gluetun.service" ];
      BindsTo = [ "gluetun.service" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/mousehole/data 0755 1000 1000 -"
  ];

  services.restic.backups.apps = {
    paths = [ "/var/lib/mousehole/data" ];
  };
}
