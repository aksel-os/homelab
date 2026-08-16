{
  imports = [
    ./node-exporter.nix
    ./alloy.nix
    ./tailscale.nix
    ./immich.nix # Not a container due to laziness
  ];
}
