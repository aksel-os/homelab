{ inputs, ... }:

{
  imports = [
    inputs.quadlet-nix.nixosModules.quadlet
    ./torrent
    ./arr
    ./audiobookshelf.nix
    ./jellyfin.nix
    ./bookorbit.nix
  ];

  virtualisation.quadlet.enable = true;

  virtualisation.quadlet.networks.dns = {
    networkConfig.interfaceName = "podman-dns";
  };

  networking.firewall.interfaces."podman-dns".allowedUDPPorts = [ 53 ];
}
