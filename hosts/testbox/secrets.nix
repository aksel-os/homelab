{
  inputs,
  self,
  config,
  lib,
  ...
}:

let
  inherit (lib) genAttrs;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops.defaultSopsFile = "${self}/secrets/${config.networking.hostName}";

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.secrets = genAttrs [ "wireguard/key" "wireguard/address" ] (_: {
    sopsFile = "${self}/secrets/services/wireguard.yaml";
  });
}
