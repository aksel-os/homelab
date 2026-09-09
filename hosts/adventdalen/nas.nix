{
  fileSystems."/mnt/nas" = {
    device = "100.111.132.45:/mnt/tank/data";
    fsType = "nfs";
    options = [ "nfsvers=4.2" ];
  };
  fileSystems."/mnt/backups/restic" = {
    device = "100.111.132.45:/mnt/tank/backups/restic";
    fsType = "nfs";
    options = [ "nfsvers=4.2" ];
  };

  services.traefik.dynamicConfigOptions = {
    http = {
      routers.truenas = {
        rule = "Host(`nas.internal.akselos.no`)";
        entryPoints = [ "websecure" ];
        service = "truenas";
        middlewares = [ "purescale" ];
        tls.certResolver = "letsencrypt";
      };

      services.truenas.loadBalancer.servers = [
        {
          url = "http://100.111.132.45";
        }
      ];
    };
  };
}
