{ config, ... }:

let
  inherit (config.services.sabnzbd.settings.misc) host port;

in
{
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
    settings = {
      misc = {
        host = "127.0.0.1";
        port = 43210;
      };
    };
  };
}
