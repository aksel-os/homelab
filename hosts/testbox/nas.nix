{
  # Create directory to emulate NAS
  systemd.tmpfiles.rules = [
    # One dataset
    "d /mnt/nas 0775 1000 1000 -"
    "d /mnt/nas/media 0775 1000 1000 -" # arr stack
    "d /mnt/nas/torrents 0775 1000 1000 -"
    "d /mnt/nas/usenet 0775 1000 1000 -"

    # Separate nested dataset
    "d /mnt/nas/photos 0755 root root -" # immich
    "d /mnt/nas/photos/external 0755 1000 1000 -" # immich - pre-existing photos
  ]
  ++ map (dir: "d /mnt/nas/media/${dir} 0775 1000 1000 -") [
    "movies" # Radarr/Jellyfin
    "series" # Sonarr/Jellyfin
    "anime" # Sonarr/Shoko/Jellyfin
    "books" # Shelfmark/BookOrbit
    "audiobooks" # Shelfmark/Audiobookshelf
    "music"
  ];
}
