{ config, ... }:
let
  inherit (config.virtualisation.quadlet) networks;

in
{
  virtualisation.quadlet.containers.shoko = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.shoko.rule=Host(`shoko.internal.akselos.no`)"
        "traefik.http.routers.shoko.entrypoints=websecure"
        "traefik.http.routers.shoko.tls=true"
        "traefik.http.routers.shoko.tls.certresolver=letsencrypt"
        "traefik.http.services.shoko.loadbalancer.server.port=8111"
      ];

      image = "ghcr.io/shokoanime/server:latest";
      networks = [ networks.dns.ref ];

      environments = {
        TZ = config.time.timeZone;
        PUID = "1000";
        PGID = "100";
      };
      volumes = [
        "/var/lib/shoko/config:/home/shoko/.shoko"
        "/mnt/nas/media:/data/media"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/shoko/config 0755 1000 100 -"
  ];

  services.restic.backups.apps = {
    paths = [ "/var/lib/shoko/config" ];
  };
}
