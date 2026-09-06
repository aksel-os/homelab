{ config, self, ... }:

let
  inherit (config.sops) templates;
in
{
  sops.secrets."networkmanager/paldea_wifi_psk".sopsFile =
    "${self}/secrets/services/networkmanager.yaml";

  sops.templates."networkmanager-wifi.env" = {
    content = ''
      WIFI_PSK=${config.sops.placeholder."networkmanager/paldea_wifi_psk"}
    '';
  };

  networking.networkmanager.ensureProfiles = {
    environmentFiles = [ templates."networkmanager-wifi.env".path ];

    profiles = {
      "adventdalen-lan" = {
        connection = {
          id = "adventdalen-lan";
          type = "wifi";
          interface-name = "wlp5s0";
        };
        wifi = {
          mode = "infrastructure";
          ssid = "Paldea";
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "$WIFI_PSK";
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
  };
}
