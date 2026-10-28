{ config, ... }:

let
  inherit (config.virtualisation.quadlet) pods networks;

in
{
  virtualisation.quadlet.containers.socks5 = {
    containerConfig = {
      image = "docker.io/serjs/go-socks5-proxy:latest";

      pod = pods.torrent.ref;
      startWithPod = true;

      environments = {
        PROXY_PORT = "1080";
      };
    };

    unitConfig = {
      After = [ "gluetun.service" ];
      Requires = [ "gluetun.service" ];
      BindsTo = [ "gluetun.service" ];
    };
  };

  virtualisation.quadlet.pods.torrent = {
    podConfig = {
      networks = [ networks.arr.ref ];
      publishPorts = [ "100.99.136.0:1080:1080" ];
    };
  };
}
