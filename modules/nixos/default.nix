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

    vim
    git
    dust
    yazi
  ];
}
