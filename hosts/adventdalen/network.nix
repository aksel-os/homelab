{
  networking.networkmanager.ensureProfiles.profiles = {
    "adventdalen-lan" = {
      connection = {
        id = "adventdalen-lan";
        type = "wifi";
        interface-name = "wlp5s0";
      };
      ipv4 = {
        method = "manual";
        address1 = "192.168.0.100/24";
        gateway = "192.168.0.1";
        dns = "192.168.0.1;";
      };
      ipv6.method = "auto";
    };
  };
}
