{ inputs, self, ... }:

{
  flake.nixosConfigurations =
    let
      hostsDir = ../../hosts;
      hostNames = builtins.filter (name: name != "example") (
        builtins.attrNames (
          inputs.nixpkgs.lib.filterAttrs (_: type: type == "directory") (builtins.readDir hostsDir)
        )
      );
      nixpkgs = inputs.nixpkgs;

    in
    nixpkgs.lib.genAttrs hostNames (
      name:
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs self; };
        modules = [
          (hostsDir + "/${name}")
          ../core
          ../nixos
        ];
      }
    );
}
