{ inputs, ... }:

{
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./nas.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "example";
  networking.useDHCP = true;

  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "virtio_pci"
    "sr_mod"
    "virtio_blk"
  ];

  users.users.root.initialPassword = "password";
}
