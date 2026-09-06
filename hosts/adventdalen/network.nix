{
  networking.networkmanager.ensureProfiles.profiles = {
    "adventdalen-lan" = {
      connection = {
        id = "adventdalen-lan";
        type = "ethernet";
        interface-name = "enp4s0";
      };
      ipv4 = {
        method = "manual";
        address1 = "192.168.10.10/24";
        gateway = "192.168.0.1";
        dns = "192.168.0.1;";
      };
      ipv6.method = "auto";
    };
  };
}
