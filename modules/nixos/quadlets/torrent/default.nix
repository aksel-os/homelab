{
  imports = [
    ./gluetun.nix
    ./qbittorrent.nix
  ];

  virtualisation.quadlet.pods.torrent = {
    podConfig = {
      networks = [ "arr.network" ];
      publishPorts = [ "8080:8080" ];
    };
  };
}
