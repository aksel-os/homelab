{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.sops) secrets;
  bookorbit_range = (import ../quadlets/subnets.nix).bookorbit;
in
{
  # https://wiki.nixos.org/wiki/PostgreSQL#Major_upgrades

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;
    extensions = with pkgs.postgresql18Packages; [
      pgvector
      vectorchord
    ];
    enableTCPIP = true;
    settings = {
      shared_preload_libraries = [ "vchord" ];
      listen_addresses = lib.mkForce "127.0.0.1,100.101.183.74";
    };

    authentication = lib.mkOverride 10 ''
      # TYPE DATABASE USER ADDRESS METHOD
      local all all peer
      host bookorbit bookorbit ${bookorbit_range} scram-sha-256
    '';

    ensureDatabases = [
      "bookorbit"
      "immich"
    ];
    ensureUsers = [
      {
        name = "bookorbit";
        ensureDBOwnership = true;
      }
      {
        name = "immich";
        ensureDBOwnership = true;
      }
    ];
  };

  systemd.services.postgresql.postStart = ''
    set -euo pipefail

    bookorbit=$(cat ${secrets."bookorbit/postgres_password".path})
    $PSQL -v ON_ERROR_STOP=1 \
        -v password="$bookorbit" \
        -c "ALTER ROLE bookorbit WITH PASSWORD :'password';"

    immich=$(cat ${secrets."immich/postgres_password".path})
    $PSQL -v ON_ERROR_STOP=1 \
        -v password="$immich" \
        -c "ALTER ROLE immich WITH PASSWORD :'password';"
  '';
}
