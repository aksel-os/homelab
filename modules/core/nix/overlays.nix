{ inputs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      # Now enables pkgs.unstable.<pkgs>
      unstable = inputs.nixpkgs-unstable {
        inherit (prev) system;
      };
    })
  ];
}
