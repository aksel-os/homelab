{
  inputs,
  self,
  config,
  ...
}:

{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops.defaultSopsFile = "${self}/secrets/${config.networking.hostName}.yaml";

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.secrets = {
    "testbox/passwd" = {
      neededForUsers = true;
    };

    "wireguard/key" = {
      sopsFile = "${self}/secrets/services/wireguard.yaml";
    };

    "wireguard/address" = {
      sopsFile = "${self}/secrets/services/wireguard.yaml";
    };

    "grafana/admin_password" = {
      sopsFile = "${self}/secrets/services/grafana.yaml";
      owner = "grafana";
      restartUnits = [ "grafana.service" ];
    };

    "grafana/secret_key" = {
      sopsFile = "${self}/secrets/services/grafana.yaml";
      owner = "grafana";
      restartUnits = [ "grafana.service" ];
    };
  };
}
