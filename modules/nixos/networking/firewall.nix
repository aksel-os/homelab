{
  networking = {
    firewall = {
      enable = true;

      # Defined in each service's config
      allowedTCPPorts = [ ];
      allowedTCPPortRanges = [ ];
    };

    nftables.enable = true;
  };
}
