{
  # Create directory to emulate NAS
  systemd.tmpfiles.rules = [
    "d /mnt/nas 0755 root root -"
    "d /mnt/nas/media 0755 root root -" # arr stack
    "d /mnt/nas/photos 0755 root root -" # immich
    "d /mnt/nas/photos/external 0755 1000 1000 -" # immich - pre-existing photos
  ]
  ++ map (dir: "d /mnt/nas/media/${dir} 0755 1000 1000 -") [
    "movies" # Radarr/Jellyfin
    "series" # Sonarr/Jellyfin
    "books" # Shelfmark/BookOrbit
    "audiobooks" # Shelfmark/Audiobookshelf
    "music"
  ];

  /*
    Example configuration for NAS
    fileSystems."/mnt/nas" = {
      device = "<ip-addrd>:<path>";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
        "x-systemd.idle-timeout=600"
        "x-systemd.mount-timeout=10"
        "nfsvers=4.2"
      ];
    };
  */
}
