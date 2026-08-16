{
  imports = [
    ./gluetun.nix
    ./qbittorrent.nix
  ];

  virtualisation.quadlet.pods.torrent = {
    podConfig = {
      publishPorts = [ "8080:8080" ];
    };
  };
}
