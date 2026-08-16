{ config, ... }:

let
  inherit (config.services) prometheus;

in
{
  services.grafana = {
    enable = true;

    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "${prometheus.listenAddress}:${toString prometheus.port}";
          isDefault = true;
          editable = false;
        }
        {
          name = "Loki";
          type = "loki";
          url = "127.0.0.1:3100";
          isDefault = true;
          editable = false;
        }
      ];
    };
  };
}
