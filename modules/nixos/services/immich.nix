{ pkgs, ... }:

{
  services.immich = {
    enable = true;
    package = pkgs.unstable.immich;
    host = "0.0.0.0";
  };
}
