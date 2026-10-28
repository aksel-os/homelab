{ config, ... }:

let
  inherit (config.virtualisation.quadlet) networks;

in
{
  virtualisation.quadlet.containers.suwayomi = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.suwayomi.rule=Host(`suwayomi.internal.akselos.no`)"
        "traefik.http.routers.suwayomi.entrypoints=websecure"
        "traefik.http.routers.suwayomi.tls=true"
        "traefik.http.routers.suwayomi.tls.certresolver=letsencrypt"
        "traefik.http.services.suwayomi.loadbalancer.server.port=4567"
        "traefik.http.routers.suwayomi.middlewares=purescale@file"
      ];

      image = "ghcr.io/suwayomi/tachidesk:v2.4.2435";
      networks = [
        networks.dns.ref
        networks.arr.ref
      ];

      user = "1000:1000";
      noNewPrivileges = true;

      environments = {
        TZ = config.time.timeZone;
      };

      volumes = [
        "/mnt/nas/media/manga:/home/suwayomi/.local/share/Tachidesk/downloads"
        "/var/lib/suwayomi/config:/home/suwayomi/.local/share/Tachidesk"
      ];
    };

    unitConfig = {
      After = [ "flaresolverr.service" ];
      Wants = [ "flaresolverr.service" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/suwayomi/config 0755 1000 1000 -"
    "d /var/lib/suwayomi/config/downloads 0755 1000 1000 -"
  ];

  services.restic.backups.apps = {
    paths = [ "/var/lib/suwayomi/config" ];
  };
}
