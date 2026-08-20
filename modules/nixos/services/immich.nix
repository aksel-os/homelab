{
  pkgs,
  self,
  config,
  ...
}:

let
  inherit (config.sops) secrets templates;

in
{
  sops.secrets = {
    "immich/postgres_password" = {
      sopsFile = "${self}/secrets/services/immich.yaml";
      owner = "postgres";
    };
  };

  sops.templates."immich.env" = {
    content = ''
      DB_PASSWORD=${config.sops.placeholder."immich/postgres_password"}
    '';
    # owner = "immich";
    restartUnits = [ "immich-server.service" ];
  };

  services.immich = {
    enable = false;
    package = pkgs.unstable.immich;
    host = "0.0.0.0";
    secretsFile = templates."immich.env".path;

    database = {
      enable = false;
      host = "127.0.0.1";
      name = "immich";
      user = "immich";
    };
  };
}
