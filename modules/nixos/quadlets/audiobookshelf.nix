{
  virtualisation.quadlet.containers.audiobookshelf = {
    containerConfig = {
      image = "ghcr.io/advplyr/audiobookshelf:latest";
      publishPorts = [ "13378:80" ];
      environments = {
        TZ = "Europe/Oslo";
      };

      volumes = [
        "/var/lib/audiobookshelf/config:/config"
        "/var/lib/audiobookshelf/metadata:/metadata"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/audiobookshelf/config 0755 root root -"
    "d /var/lib/audiobookshelf/metadata 0755 root root -"
  ];
}
