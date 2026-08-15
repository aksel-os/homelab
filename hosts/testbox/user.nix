{ config, ... }:

{
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

    # hashedPasswordFile = config.sops.secrets.passwd;
    hashedPassword = "$y$j9T$dPb2xAQb4YQyk2G5AQO6C0$NaInkWbv.zzHPXPO1Bn6QubKx82E8eQq38v7XSr0DI/";
  };
}
