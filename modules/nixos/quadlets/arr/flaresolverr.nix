{ config, ... }:

let
  inherit (config.virtualisation.quadlet) networks;

in
{
  # Port: 8191
  virtualisation.quadlet.containers.flaresolverr = {
    containerConfig = {
      image = "ghcr.io/flaresolverr/flaresolverr:latest";
      networks = [ networks.arr.ref ];

      environments = {
        TZ = config.time.timeZone;
      };
    };
  };
}
