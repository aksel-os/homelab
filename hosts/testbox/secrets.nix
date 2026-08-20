{
  inputs,
  self,
  config,
  ...
}:

{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops.defaultSopsFile = "${self}/secrets/${config.networking.hostName}.yaml";

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
}
