{ inputs, self, ... }:

{
  flake.nixosConfigurations =
    let
      hostsDir = ../../hosts;
      hostNames = builtins.attrNames (
        inputs.nixpkgs.lib.filterAttrs (_: type: type == "directory") (builtins.readDir hostsDir)
      );
      nixpkgs = inputs.nixpkgs;

    in
    nixpkgs.lib.genAttrs hostNames (
      name:
      nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs self; };
        modules = [
          (hostsDir + "/${name}")
          ../core
          ../nixos
        ];
      }
    );
}
