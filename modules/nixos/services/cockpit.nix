{
  services.cockpit = {
    enable = true;
    port = 9095;
    settings = {
      WebService = {
        AllowUnencrypted = true;
      };
    };
  };

  services.traefik.dynamicConfigOptions = {
    http = {
      routers.cockpit = {
        rule = "Host(`cockpit.internal.akselos.no`)";
        entryPoints = [ "websecure" ];
        service = "cockpit";
        middlewares = [ "purescale@file" ];
        tls.certResolver = "letsencrypt";
      };

      services.cockpit.loadBalancer.servers = [
        { url = "http://127.0.0.1:9095"; }
      ];
    };
  };
}
