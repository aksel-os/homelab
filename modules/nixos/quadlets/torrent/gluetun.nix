{ config, self, ... }:

let
  inherit (config.virtualisation.quadlet) pods;
  inherit (config.sops) secrets templates;
in
{
  sops.secrets = {
    "wireguard/private_key".sopsFile = "${self}/secrets/services/wireguard.yaml";
    "wireguard/preshared_key".sopsFile = "${self}/secrets/services/wireguard.yaml";
    "wireguard/address".sopsFile = "${self}/secrets/services/wireguard.yaml";
    "wireguard/forwarded_port".sopsFile = "${self}/secrets/services/wireguard.yaml";
  };

  sops.templates."gluetun.env" = {
    content = ''
      FIREWALL_VPN_INPUT_PORTS=${config.sops.placeholder."wireguard/forwarded_port"}
    '';
    restartUnits = [ "gluetun.service" ];
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
        "${secrets."wireguard/private_key".path}:/run/secrets/wireguard/private_key:ro"
        "${secrets."wireguard/preshared_key".path}:/run/secrets/wireguard/preshared_key:ro"
        "${secrets."wireguard/address".path}:/run/secrets/wireguard/address:ro"
      ];

      healthCmd = "wget -qO- https://ifconfig.co";
      healthInterval = "30s";
      healthTimeout = "10s";
      healthRetries = 3;

      environmentFiles = [ templates."gluetun.env".path ];

      environments = {
        TZ = config.time.timeZone;
        VPN_SERVICE_PROVIDER = "airvpn";
        VPN_TYPE = "wireguard";
        WIREGUARD_PRIVATE_KEY_SECRETFILE = "/run/secrets/wireguard/private_key";
        WIREGUARD_PRESHARED_KEY_SECRETFILE = "/run/secrets/wireguard/preshared_key";
        WIREGUARD_ADDRESSES_SECRETFILE = "/run/secrets/wireguard/address";
        WIREGUARD_MTU = "1280";
        HTTPPROXY = "on";
        HTTPPROXY_STEALTH = "on";
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/gluetun/config 0755 root root -"
  ];
}
