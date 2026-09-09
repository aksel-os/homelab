{ inputs, ... }:

{
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./swap.nix
    ./nas.nix
    ./secrets.nix
    ./user.nix
    ./network.nix
  ];

  nixpkgs.hostPlatform = {
    system = "x86_64-linux";
  };

  hardware.enableRedistributableFirmware = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = {
    nfs = true;
  };

  networking.hostName = "adventdalen";
  networking.networkmanager.enable = true;
  networking.firewall.interfaces."enp4s0".allowedTCPPorts = [ 22 ];
  networking.firewall.interfaces."wlp5s0".allowedTCPPorts = [ 22 ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usb_storage"
    "sd_mod"
  ];

  console.keyMap = "no";
  time.timeZone = "Europe/Oslo";
}
