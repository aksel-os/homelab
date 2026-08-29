{ config, ... }:

let
  inherit (config.virtualisation.quadlet) networks;

in
{
  imports = [
    ./gluetun.nix
    ./qbittorrent.nix
    ./shelfmark.nix
    ./qui.nix
  ];

  virtualisation.quadlet.pods.torrent = {
    podConfig = {
      networks = [ networks.arr.ref ];
    };
  };
}
