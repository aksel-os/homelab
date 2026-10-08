{ pkgs, ... }:

{
  imports = [
    ./networking
    ./services
    ./quadlets
    ./podman.nix
  ];

  environment.systemPackages = with pkgs; [
    gallery-dl
    yt-dlp

    unzip
    vim
    git
    dust
    just
    yazi

    lm_sensors
  ];
}
