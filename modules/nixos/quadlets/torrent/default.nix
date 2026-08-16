{
  imports = [
    ./gluetun.nix
    ./qbittorrent.nix
  ];

  virtualisation.quadlet.pods.torrent = {
    podConfig = {
      publishedPorts = [ "8080:8080" ];
    };
  };
}
