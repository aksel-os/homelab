{
  imports = [
    ./prowlarr.nix
    ./radarr.nix
    ./sonarr.nix
    ./seerr.nix
    ./shelfmark.nix
    ./bookorbit.nix
  ];

  virtualisation.quadlet.networks.arr = {
    networkConfig.interfaceName = "dns-arr";
  };

  networking.firewall.interfaces."dns-arr".allowedUDPPorts = [ 53 ];
}
