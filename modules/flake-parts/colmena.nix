{ inputs, self, ... }:

{
  flake.colmena = {
    meta = {
      nixpkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
      };

      specialArgs = { inherit inputs self; };
    };

    /*
      example = { pkgs, ... }: {
        deployment = {
          targetHost = "192.168.0.10";
          targetUser = "root";
          buildOnTarget = true;
        };

        imports = [
          ../../hosts/example
          ../core
          ../nixos
        ];
      };
    */
  };
}
