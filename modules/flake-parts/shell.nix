{
  systems = [
    "aarch64-darwin"
    "x86_64-linux"
  ];

  perSystem =
    { pkgs, ... }:
    {
      devShells = {
        default = pkgs.mkShellNoCC {
          name = "homelab-shell";
          meta.description = "Dev environment for homelab";

          packages = [
            pkgs.just
            pkgs.git
            pkgs.zsh
            pkgs.colmena
            pkgs.sops
            pkgs.age
          ];

          shellHook = ''
            echo "Homelab dev shell loaded with Colmena"
          '';
        };
      };
    };
}
