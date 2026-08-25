{
  imports = [
    ./monitoring
    ./dashboard
    ./immich.nix # Not a container due to laziness
    ./postgres.nix
    ./recyclarr.nix
    ./sabnzbd.nix
  ];
}
