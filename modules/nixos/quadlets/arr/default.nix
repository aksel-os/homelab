{
  imports = [
    ./prowlarr.nix
    ./radarr.nix
    ./sonarr.nix
  ];

  virtualisation.quadlet.networks.arr = { };
}
