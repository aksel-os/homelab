{ config, self, ... }:

let
  inherit (config.services) prometheus;
  inherit (config.sops) secrets;

in
{
  sops.secrets = {
    "grafana/admin_password" = {
      sopsFile = "${self}/secrets/services/grafana.yaml";
      owner = "grafana";
      restartUnits = [ "grafana.service" ];
    };

    "grafana/secret_key" = {
      sopsFile = "${self}/secrets/services/grafana.yaml";
      owner = "grafana";
      restartUnits = [ "grafana.service" ];
    };
  };

  services.grafana = {
    enable = true;

    settings = {
      security = {
        admin_password = "$__file{${secrets."grafana/admin_password".path}}";
        secret_key = "$__file{${secrets."grafana/secret_key".path}}";
      };

      server = {
        http_addr = "0.0.0.0";
      };
    };

    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://${prometheus.listenAddress}:${toString prometheus.port}";
          editable = false;
        }
        {
          name = "Loki";
          type = "loki";
          url = "http://127.0.0.1:3100";
          editable = false;
        }
      ];
    };
  };
}
