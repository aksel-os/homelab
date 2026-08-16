{
  networking = {
    firewall = {
      enable = true;

      allowedTCPPorts = [ ];
      allowedTCPPortRanges = [ ];
    };

    nftables.enable = true;
  };
}
