{ inputs, ... }:

{
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./nas.nix
    ./secrets.nix
    ./user.nix
  ];

  nixpkgs.hostPlatform = {
    system = "aarch64-linux";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "testbox";
  networking.useDHCP = true;

  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "virtio_pci"
    "sr_mod"
    "virtio_blk"
  ];

  console.keyMap = "no";
}
