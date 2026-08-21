{
  virtualisation.quadlet.containers.jellyfin = {
    containerConfig = {
      image = "docker.io/jellyfin/jellyfin:latest";
      publishPorts = [ "8096:8096" ];
      volumes = [
        "/var/lib/jellyfin/config:/config"
        "/var/lib/jellyfin/cache:/cache"
        "/mnt/nas/media/movies:/movies"
        "/mnt/nas/media/series:/series"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/jellyfin/config 0755 root root -"
    "d /var/lib/jellyfin/cache 0755 root root -"
  ];
}
