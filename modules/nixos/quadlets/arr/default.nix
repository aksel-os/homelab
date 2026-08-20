{
  imports = [
    ./prowlarr.nix
    ./radarr.nix
    ./sonarr.nix
  ];

  virtualisation.quadlet.networks.arr = {
    networkConfig.interfaceName = "dns-arr";
  };

  networking.firewall.interfaces."dns-arr".allowedUDPPorts = [ 53 ];
}
