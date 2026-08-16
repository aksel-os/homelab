{ inputs, ... }:

{
  imports = [
    inputs.quadlet-nix.nixosModules.quadlet
    ./torrent
    ./arr
    ./audiobookshelf.nix
    ./jellyfin.nix
  ];

  virtualisation.quadlet.enable = true;
}
