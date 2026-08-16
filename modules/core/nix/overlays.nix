{ inputs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      # Now enables pkgs.unstable.<pkgs>
      unstable = import inputs.nixpkgs-unstable {
        inherit (prev.stdenv.hostPlatform) system;
      };
    })
  ];
}
