{
  imports = [
    ./monitoring
    ./immich.nix # Not a container due to laziness
    ./postgres.nix
    ./recyclarr.nix
  ];
}
