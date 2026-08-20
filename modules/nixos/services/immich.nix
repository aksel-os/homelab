{ pkgs, self, ... }:

{
  sops.secrets = {
    "immich/postgres_password" = {
      sopsFile = "${self}/secrets/services/immich.yaml";
    };
  };

  services.immich = {
    enable = true;
    package = pkgs.unstable.immich;
    host = "0.0.0.0";

    database = {
      enable = false;
      host = "127.0.0.1";
      name = "immich";
      user = "immich";
    };
  };
}
