{ config, ... }:

{
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;

    settings = {
      interface = config.services.tailscale.interfaceName;
      bind-interfaces = true;

      no-resolv = true;
      server = [
        "1.1.1.1"
        "1.0.0.1"
      ];

      address = [ "/internal.akselos.no/100.101.183.74" ];
    };
  };
}
