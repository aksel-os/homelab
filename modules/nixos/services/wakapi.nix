{ self, config, ... }:

let
  inherit (config.sops) templates;

in
{
  sops.secrets."wakapi/password_salt" = {
    sopsFile = "${self}/secrets/services/wakapi.yaml";
  };

  sops.templates."wakapi.env" = {
    content = ''
      WAKAPI_PASSWORD_SALT=${config.sops.placeholder."wakapi/password_salt"}
    '';
    owner = "wakapi";
    restartUnits = [ "wakapi.service" ];
  };

  services.traefik.dynamicConfigOptions = {
    http = {
      routers.wakapi = {
        rule = "Host(`wakapi.internal.akselos.no`)";
        entryPoints = [ "websecure" ];
        service = "wakapi";
        middlewares = [ "purescale" ];
        tls.certResolver = "letsencrypt";
      };

      services.wakapi.loadBalancer.servers = [
        {
          url = "http://127.0.0.1:8642";
        }
      ];
    };
  };

  services.wakapi = {
    enable = true;
    environmentFiles = [ templates."wakapi.env".path ];
    database.createLocally = true;

    settings = {
      server = {
        port = 8642;
        public_url = "https://wakapi.internal.akselos.no";
      };

      db = {
        dialect = "postgres";
        host = "/run/postgresql";
        port = 5432;
        name = "wakapi";
        user = "wakapi";
      };

      security = {
        allow_signup = false;
        disable_frontpage = true;
      };
    };
  };

  services.postgresql = {
    ensureDatabases = [ "wakapi" ];
    ensureUsers = [
      {
        name = "wakapi";
        ensureDBOwnership = true;
      }
    ];
  };
}
