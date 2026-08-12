{ inputs, ... }:

{
  flake.configurations =
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
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          (hostsDir + name)
          ../core
          ../nixos
        ];
      }
    );
}
