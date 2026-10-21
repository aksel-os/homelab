{ config, self, ... }:

let
  inherit (config.sops) templates;

in
{
  sops.secrets."gotify/admin_password".sopsFile = "${self}/secrets/services/gotify.yaml";

  sops.templates."gotify.env" = {
    content = ''
      GOTIFY_DEFAULTUSER_PASS=${config.sops.placeholder."gotify/admin_password"}
    '';
    restartUnits = [ "gotify-server.service" ];
  };

  services.gotify = {
    enable = true;
    environmentFiles = [ templates."gotify.env".path ];
    environment = {
      GOTIFY_SERVER_LISTENADDR = "127.0.0.1";
      GOTIFY_SERVER_PORT = 8070;
      # GOTIFY_REGISTRATION = "false";
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.gotify = {
      rule = "Host(`gotify.internal.akselos.no`)";
      entryPoints = [ "websecure" ];
      service = "gotify";
      middlewares = [ "purescale" ];
      tls.certResolver = "letsencrypt";
    };
    services.gotify.loadBalancer.servers = [ { url = "http://127.0.0.1:8070"; } ];
  };

  services.restic.backups.apps.paths = [ "/var/lib/gotify-server" ];
}
