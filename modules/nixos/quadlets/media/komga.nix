{ config, ... }:

let
  inherit (config.virtualisation.quadlet) networks;

in
{
  virtualisation.quadlet.containers.komga = {
    containerConfig = {
      labels = [
        "traefik.enable=true"
        "traefik.http.routers.komga.rule=Host(`komga.internal.akselos.no`)"
        "traefik.http.routers.komga.entrypoints=websecure"
        "traefik.http.routers.komga.tls=true"
        "traefik.http.routers.komga.tls.certresolver=letsencrypt"
        "traefik.http.services.komga.loadbalancer.server.port=25600"
        "traefik.http.routers.komga.middlewares=purescale@file"
      ];

      image = "docker.io/gotson/komga:1.29.2";
      networks = [ networks.dns.ref ];

      user = "1000:1000";
      noNewPrivileges = true;
      dropCapabilities = [ "ALL" ];

      environments = {
        TZ = config.time.timeZone;
        JAVA_TOOL_OPTIONS = "-Xmx1g";
      };

      volumes = [
        "/var/lib/komga/config:/config"
        "/mnt/nas/media/comics:/data/comics:ro"
        "/mnt/nas/media/manga:/data/manga:ro"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/komga/config 0755 1000 1000 -"
  ];

  services.restic.backups.apps = {
    paths = [ "/var/lib/komga/config" ];
  };
}
