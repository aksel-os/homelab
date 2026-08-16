{ self, ... }:

{
  services.loki = {
    enable = true;

    configFile = "${self}/containers/observability/loki/config/loki.yaml";
  };
}
