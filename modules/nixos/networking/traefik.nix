{ config, self, ... }:

{
  sops.secrets = {
    "traefik/api_token".sopsFile = "${self}/secrets/services/traefik.yaml";
    "traefik/api_secret".sopsFile = "${self}/secrets/services/traefik.yaml";
  };

  sops.templates."traefik.env" = {
    content = ''
      DOMENESHOP_API_TOKEN=${config.sops.placeholder."traefik/api_token"}
      DOMENESHOP_API_SECRET=${config.sops.placeholder."traefik/api_secret"}
    '';
    restartUnits = [ "traefik.service" ];
  };

  users.users.traefik.extraGroups = [ "podman" ];

  services.traefik = {
    enable = true;
    environmentFiles = [ config.sops.templates."traefik.env".path ];

    staticConfigOptions = {
      entryPoints = {
        web = {
          address = ":80";
          http.redirections.entryPoint = {
            to = "websecure";
            scheme = "https";
          };
        };

        websecure.address = ":443";
      };

      providers.docker = {
        endpoint = "unix:///run/podman/podman.sock";
        exposedByDefault = false;
      };

      certificatesResolvers.letsencrypt.acme = {
        email = "info@akselos.no";
        storage = "${config.services.traefik.dataDir}/acme.json";
        dnsChallenge = {
          provider = "domeneshop";
          resolvers = [
            "1.1.1.1:53"
            "1.0.0.1:53"
          ];
        };
      };
    };
  };
}
