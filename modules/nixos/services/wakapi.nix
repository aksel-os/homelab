{
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
