{ config, self, ... }:
let
  inherit (config.virtualisation.quadlet) networks;

in
{
  sops.secrets = {
    "jellyfin/api_key" = {
      sopsFile = "${self}/secrets/services/jellyfin.yaml";
    };
  };

  virtualisation.quadlet.containers.jellyfin = {
    containerConfig = {
      image = "docker.io/jellyfin/jellyfin:latest";
      networks = [ networks.dns.ref ];
      publishPorts = [ "8096:8096" ];
      volumes = [
        "/var/lib/jellyfin/config:/config"
        "/var/lib/jellyfin/cache:/cache"
        "/mnt/nas/media/movies:/movies"
        "/mnt/nas/media/series:/series"
        "/mnt/nas/media/anime:/anime"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/jellyfin/config 0755 root root -"
    "d /var/lib/jellyfin/cache 0755 root root -"
  ];
}
