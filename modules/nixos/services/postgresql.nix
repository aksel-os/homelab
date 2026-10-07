{ pkgs, ... }:

{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;

    ensureUsers = [
      {
        name = "postgres";
        ensureClauses = {
          superuser = true;
          createrole = true;
          createdb = true;
          replication = true;
          login = true;
        };
      }
    ];
  };
}
