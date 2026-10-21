{
  services.beszel = {
    hub = {
      enable = true;
      host = "127.0.0.1";
      port = 8090;
      environment.APP_URL = "https://beszel.internal.akselos.no";
    };

    agent = {
      enable = true;
      smartmon.enable = true;
      environment = {
        LISTEN = "127.0.0.1:45876";
        DOCKER_HOST = "unix:///run/podman/podman.sock";
        KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM80/+uCXHOyJIjCLFSyE6P3VdWnfvUI1kwxlFYOyk49";
      };
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.beszel = {
      rule = "Host(`beszel.internal.akselos.no`)";
      entryPoints = [ "websecure" ];
      service = "beszel";
      middlewares = [ "purescale" ];
      tls.certResolver = "letsencrypt";
    };
    services.beszel.loadBalancer.servers = [ { url = "http://127.0.0.1:8090"; } ];
  };

  services.restic.backups.apps.paths = [ "/var/lib/beszel-hub" ];
}
