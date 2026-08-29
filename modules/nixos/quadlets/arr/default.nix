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
    networkConfig = {
      interfaceName = "dns-arr";
      dns = [
        "1.1.1.1" # Cloudflare
        "1.0.0.1"
        "9.9.9.9" # Quad9
        "149.112.112.112"
        "8.8.8.8" # Google (keeps logs)
        "8.8.4.4"
      ];
    };
  };

  networking.firewall.interfaces."dns-arr".allowedUDPPorts = [ 53 ];
}
