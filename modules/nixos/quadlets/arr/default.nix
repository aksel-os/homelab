{
  imports = [
    ./prowlarr.nix
    ./radarr.nix
    ./sonarr.nix
    ./sonani.nix
    ./seerr.nix
    ./flaresolverr.nix
    ./bindery.nix
  ];

  virtualisation.quadlet.networks.arr = {
    networkConfig.interfaceName = "dns-arr";
  };

  networking.firewall.interfaces."dns-arr".allowedUDPPorts = [ 53 ];
}
