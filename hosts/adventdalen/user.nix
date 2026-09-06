{ config, ... }:

{
  sops.secrets."testbox/passwd".neededForUsers = true;

  users.users.admin = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "nix"
      "network"
      "networkmanager"
      "sops-nix"
      "podman"

    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFXXVv2ocQ7Rad2icTVKNzv5aZDB0vOqayrfZ5uv/Cok admin-homelab"
    ];

    hashedPasswordFile = config.sops.secrets."testbox/passwd".path;
  };
}
