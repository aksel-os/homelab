{
  networking = {
    firewall = {
      enable = true;

      # Defined in each service's config
      allowedTCPPorts = [
        8080
        7476
        3000
        3100
        9090
        9100
        12345
      ];
      allowedTCPPortRanges = [ ];
    };

    nftables.enable = true;
  };
}
