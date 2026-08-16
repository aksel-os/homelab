{
  networking = {
    firewall = {
      enable = true;

      allowedTCPPorts = [ ];
      allowedTCPPortRanges = [ ];

      # None of these are needed, but i have added them as a note for the
      # future
      interfaces = {
        # enabled globally on openssh.openFirewall = true
        eth0.allowedTCPPorts = [ 22 ];

        # lo is inherently trusted, and host.containers.internal is mapped
        # through lo. There is no need to open on any podman* interface
        podman0 = {
          allowedTCPPorts = [
            9100
            12345
          ];
        };
      };
    };

    nftables.enable = true;
  };
}
