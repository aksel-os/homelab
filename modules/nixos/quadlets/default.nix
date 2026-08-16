{ inputs, ... }:

{
  imports = [
    inputs.quadlet-nix.nixosModules.quadlet
    ./torrent
  ];

  virtualisation.quadlet.enable = true;
}
