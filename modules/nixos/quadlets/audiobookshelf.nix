{ config, ... }:

let
  inherit (config.virtualisation.quadlet) networks;
in
{
  virtualisation.quadlet.containers.audiobookshelf = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.audiobookshelf.rule=Host(`audiobookshelf.internal.akselos.no`)"
        "traefik.http.routers.audiobookshelf.entrypoints=websecure"
        "traefik.http.routers.audiobookshelf.tls=true"
        "traefik.http.routers.audiobookshelf.tls.certresolver=letsencrypt"
        "traefik.http.services.audiobookshelf.loadbalancer.server.port=80"
      ];

      image = "ghcr.io/advplyr/audiobookshelf:latest";
      networks = [ networks.dns.ref ];
      publishPorts = [ "13378:80" ];
      environments = {
        TZ = config.time.timeZone;
      };

      volumes = [
        "/var/lib/audiobookshelf/config:/config"
        "/var/lib/audiobookshelf/metadata:/metadata"
        "/mnt/nas/media/audiobooks:/audiobooks"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/audiobookshelf/config 0755 root root -"
    "d /var/lib/audiobookshelf/metadata 0755 root root -"
  ];
}
