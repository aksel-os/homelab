{ inputs, ... }:

{
  imports = [
    inputs.quadlet-nix.nixosModules.quadlet
    ./torrent
    ./arr
  ];

  virtualisation.quadlet.enable = true;
}
