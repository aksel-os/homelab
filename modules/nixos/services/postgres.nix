{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.sops) secrets;
  inherit (config.virtualisation.quadlet) networks;
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
      listen_addresses = "127.0.0.1,100.101.183.74";
    };

    authentication = lib.mkOverride 10 ''
      # TYPE DATABASE USER ADDRESS METHOD
      local all all peer
      host  bookorbit  bookorbit  ${networks.bookorbit.subnet}  scram-sha-256
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
    ];
  };

  systemd.services.postgresql.postStart = ''
    set -euo pipefail

    bookorbit_password=$(cat ${secrets."bookorbit/postgres_password".path})
    $PSQL -v ON_ERROR_STOP=1 \
        -v password="$bookorbit_password" \
        -c "ALTER ROLE bookorbit WITH PASSWORD :'password';"
  '';
}
