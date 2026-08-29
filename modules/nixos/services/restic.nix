{ config, self, ... }:
let
  inherit (config.sops) secrets;

in
{
  sops.secrets."restic/repository_password".sopsFile = "${self}/secrets/services/restic.yaml";

  services.restic.backups = {
    apps = {
      repository = "/mnt/nas/backups/restic/apps";
      passwordFile = secrets."restic/repository_password".path;
      initialize = true;

      timerConfig = {
        OnCalendar = "daily";
        RandomizedDelaySec = "1h";
        Persistent = true;
      };

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 6"
      ];

      runCheck = true;
      checkOpts = [ "--with-cache" ];
    };

    postgres = {
      repository = "/mnt/nas/backups/restic/postgres";
      passwordFile = secrets."restic/repository_password".path;
      initialize = true;
      user = "postgres";

      command = [
        "${config.services.postgresql.package}/bin/pg_dumpall"
      ];

      timerConfig = {
        OnCalendar = "daily";
        RandomizedDelaySec = "30m";
        Persistent = true;
      };

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
      ];
    };
  };
}
