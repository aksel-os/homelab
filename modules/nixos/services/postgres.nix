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
    enable = false;
    package = pkgs.postgresql_18;
    extensions = with pkgs.postgresql18Packages; [
      pgvector
      vectorchord
    ];
    enableTCPIP = true;
    settings = {
      shared_preload_libraries = [ "vchord" ];
      listen_addresses = lib.mkForce "*";
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
        ensureClauses = {
          superuser = true;
        };
      }
    ];
  };

  # Made by an LLM as I have little interest in psql passwd management
  # The hope is that a passwordFile type option is added in the future
  systemd.services."postgresql-set-passwords" = {
    description = "Set PostgreSQL role passwords from sops";
    after = [ "postgresql.target" ];
    requires = [ "postgresql.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      RemainAfterExit = true;
    };

    path = [ config.services.postgresql.package ];

    script = ''
      set -euo pipefail

      psql -v ON_ERROR_STOP=1 -tA <<'EOF'
        DO $$
        DECLARE pw text;
        BEGIN
          pw := trim(both from replace(pg_read_file('${
            secrets."bookorbit/postgres_password".path
          }'), E'\n', '''));
          EXECUTE format('ALTER ROLE bookorbit WITH PASSWORD %L', pw);

          pw := trim(both from replace(pg_read_file('${
            secrets."immich/postgres_password".path
          }'), E'\n', '''));
          EXECUTE format('ALTER ROLE immich WITH PASSWORD %L', pw);
        END $$;
      EOF
    '';
  };
}
