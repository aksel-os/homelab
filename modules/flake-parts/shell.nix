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

          packages = with pkgs; [
            just
            git
            zsh
            colmena
            sops
            age
            ssh-to-age
          ];

          shellHook = ''
            echo "Homelab dev shell loaded with Colmena"
          '';
        };
      };
    };
}
