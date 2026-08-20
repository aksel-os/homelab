{ config, self, ... }:

let
  inherit (config.sops) templates;
  inherit (config.virtualisation.quadlet) networks;

in
{
  sops.secrets = {
    "bookorbit/postgres_password" = {
      sopsFile = "${self}/secrets/services/bookorbit.yaml";
      owner = "postgres";
    };

    "bookorbit/jwt_secret" = {
      sopsFile = "${self}/secrets/services/bookorbit.yaml";
    };

    "bookorbit/setup_bootstrap_token" = {
      sopsFile = "${self}/secrets/services/bookorbit.yaml";
    };
  };

  sops.templates."bookorbit.env" = {
    content = ''
      POSTGRES_PASSWORD=${config.sops.placeholder."bookorbit/postgres_password"}
      JWT_SECRET=${config.sops.placeholder."bookorbit/jwt_secret"}
      SETUP_BOOTSTRAP_TOKEN=${config.sops.placeholder."bookorbit/setup_bootstrap_token"}
    '';
    owner = "root";
    restartUnits = [
      "bookorbit.service"
    ];
  };

  virtualisation.quadlet.networks.bookorbit = {
    networkConfig.subnets = [ (import ./subnets.nix).bookorbit ];
  };

  networking.firewall.interfaces."bookorbit".allowedUDPPorts = [ 53 ];

  virtualisation.quadlet.containers.bookorbit = {
    containerConfig = {
      image = "ghcr.io/bookorbit/bookorbit:latest";
      networks = [ networks.bookorbit.ref ];
      publishPorts = [ "3030:3000" ];

      readOnly = true;
      tmpfses = [ "/tmp" ];
      noNewPrivileges = true;
      dropCapabilities = [ "ALL" ];
      addCapabilities = [
        "CHOWN"
        "DAC_OVERRIDE"
        "FOWNER"
        "SETGID"
        "SETUID"
      ];

      environments = {
        NODE_ENV = "production";
        PORT = "3030";
        POSTGRES_HOST = "host.containers.internal";
        POSTGRES_PORT = "5432";
        POSTGRES_USER = "bookorbit";
        POSTGRES_DB = "bookorbit";
        APP_URL = "http://localhost:3030";
        PUID = "1000";
        PGID = "1000";
      };

      environmentFiles = [ templates."bookorbit.env".path ];

      volumes = [
        "/var/lib/bookorbit/app/data:/data"
        "/mnt/nas/media/books:/books"
      ];

      healthCmd = ''node -e "const p=process.env.PORT||3000;fetch('http://127.0.0.1:'+p+'/api/v1/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"'';
      healthInterval = "30s";
      healthTimeout = "5s";
      healthRetries = 3;
      healthStartPeriod = "20s";
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/bookorbit/app/data 0755 1000 1000 -"
  ];
}
