{ config, self, ... }:

let
  inherit (config.services.sabnzbd.settings.misc) host port;
  inherit (config.sops) secrets;

in
{
  sops.secrets."sabnzbd/api_key".sopsFile = "${self}/secrets/services/sabnzbd.yaml";
  sops.secrets."sabnzbd/nzb_key".sopsFile = "${self}/secrets/services/sabnzbd.yaml";
  sops.secrets."sabnzbd/username".sopsFile = "${self}/secrets/services/sabnzbd.yaml";
  sops.secrets."sabnzbd/password".sopsFile = "${self}/secrets/services/sabnzbd.yaml";

  sops.templates."sabnzbd-secrets.ini" = {
    content = ''
      [misc]
      api_key = ${config.sops.placeholder."sabnzbd/api_key"}
      nzb_key = ${config.sops.placeholder."sabnzbd/nzb_key"}
      username = ${config.sops.placeholder."sabnzbd/username"}
      password = ${config.sops.placeholder."sabnzbd/password"}
    '';
    owner = "sabnzbd";
    restartUnits = [ "sabnzbd.service" ];
  };

  services.traefik.dynamicConfigOptions = {
    http = {
      routers.sabnzbd = {
        rule = "Host(`sab.internal.akselos.no`)";
        entryPoints = [ "websecure" ];
        service = "sabnzbd";
        middlewares = [ "purescale" ];
        tls.certResolver = "letsencrypt";
      };

      services.sabnzbd.loadBalancer.servers = [
        {
          url = "http://${host}:${toString port}";
        }
      ];
    };
  };

  services.sabnzbd = {
    enable = true;
    secretFiles = [
      config.sops.templates."sabnzbd-secrets.ini".path
    ];
    settings = {
      misc = {
        host = "127.0.0.1";
        port = 43210;
        local_ranges = "100.64.0.0/10";
        host_whitelist = "sab.internal.akselos.no";

      };
    };
  };
}
