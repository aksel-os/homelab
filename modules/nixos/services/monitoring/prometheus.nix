{ config, ... }:

let
  inherit (config.services) prometheus;
  inherit (config.services.prometheus.exporters) node;

in
{
  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";

    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [
          {
            targets = [ "${prometheus.listenAddress}:${toString prometheus.port}" ];
          }
        ];
      }
      {
        job_name = "node";
        static_configs = [
          {
            targets = [ "${node.listenAddress}:${toString node.port}" ];
          }
        ];
      }
      {
        job_name = "alloy";
        static_configs = [
          {
            targets = [ "127.0.0.1:12345" ];
          }
        ];
      }
    ];
  };
}
