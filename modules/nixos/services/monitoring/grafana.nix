{ config, ... }:

let
  inherit (config.services) prometheus;
  inherit (config.sops) secrets;

in
{
  services.grafana = {
    enable = true;

    security = {
      adminPassword = "$__file{${secrets."grafana/admin_password".path}}";
      secretKey = "$__file{${secrets."grafana/secret_key".path}}";
    };

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
