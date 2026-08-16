{ config, ... }:

let
  inherit (config.virtualisation.quadlet) pods;
  inherit (config.sops) secrets;
in
{
  virtualisation.quadlet.containers.gluetun = {
    containerConfig = {
      image = "docker.io/qmcgaw/gluetun:v3";

      pod = pods.torrent.ref;
      startWithPod = true;

      addCapabilities = [ "NET_ADMIN" ];
      devices = [ "/dev/net/tun:/dev/net/tun" ];

      volumes = [ "/var/lib/gluetun/config:/gluetun" ];

      healthCmd = "wget -qO- https://am.i.mullvad.net/connected";
      healthInterval = "30s";
      healthTimeout = "10s";
      healthRetries = 3;

      environments = {
        TZ = "Europe/Oslo"; # Change to target time.timeZone
        VPN_SERVICE_PROVIDER = "mullvad";
        VPN_TYPE = "wireguard";
        WIREGUARD_PRIVATE_KEY_SECRETFILE = secrets."wireguard/key".path;
        WIREGUARD_ADDRESSES_SECRETFILE = secrets."wireguard/address".path;
      };
    };
  };
}
