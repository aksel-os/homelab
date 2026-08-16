{
  imports = [
    ./prowlarr.nix
    ./radarr.nix
    ./sonarr.nix
  ];

  virtualisation.quadlet.pods.arr = { };

  virtualisation.quadlet.networks.arr = { };
}
