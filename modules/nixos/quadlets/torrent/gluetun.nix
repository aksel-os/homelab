{ config, self, ... }:

let
  inherit (config.virtualisation.quadlet) pods;
  inherit (config.sops) secrets;
in
{
  sops.secrets = {
    "wireguard/key".sopsFile = "${self}/secrets/services/wireguard.yaml";
    "wireguard/address".sopsFile = "${self}/secrets/services/wireguard.yaml";
  };

  virtualisation.quadlet.containers.gluetun = {
    containerConfig = {
      image = "docker.io/qmcgaw/gluetun:v3";

      pod = pods.torrent.ref;
      startWithPod = true;

      addCapabilities = [ "NET_ADMIN" ];
      devices = [ "/dev/net/tun:/dev/net/tun" ];

      volumes = [
        "/var/lib/gluetun/config:/gluetun"
        "${secrets."wireguard/key".path}:/run/secrets/wireguard/key:ro"
        "${secrets."wireguard/address".path}:/run/secrets/wireguard/address:ro"
      ];

      healthCmd = "wget -qO- https://am.i.mullvad.net/connected";
      healthInterval = "30s";
      healthTimeout = "10s";
      healthRetries = 3;

      environments = {
        TZ = "Europe/Oslo"; # Change to target time.timeZone

        VPN_SERVICE_PROVIDER = "mullvad";
        VPN_TYPE = "wireguard";

        WIREGUARD_PRIVATE_KEY_SECRETFILE = "/run/secrets/wireguard/key";
        WIREGUARD_ADDRESSES_SECRETFILE = "/run/secrets/wireguard/address";
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/gluetun/config 0755 root root -"
  ];
}
