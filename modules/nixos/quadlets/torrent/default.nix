{ config, ... }:

let
  inherit (config.virtualisation.quadlet) networks;

in
{
  imports = [
    ./gluetun.nix
    ./qbittorrent.nix
    ./qbitrace.nix
    ./shelfmark.nix
    ./qui.nix
    ./browser.nix
    ./socks5.nix
  ];

  virtualisation.quadlet.pods.torrent = {
    podConfig = {
      networks = [ networks.arr.ref ];
    };
  };
}
