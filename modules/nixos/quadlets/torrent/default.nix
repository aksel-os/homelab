{ config, ... }:

let
  inherit (config.virtualisation.quadlet) networks;

in
{
  imports = [
    ./gluetun.nix
    ./qbittorrent.nix
  ];

  virtualisation.quadlet.pods.torrent = {
    podConfig = {
      networks = [ networks.arr.ref ];
      publishPorts = [ "8080:8080" ];
    };
  };
}
