{
  services.alloy = {
    enable = true;

    extraFlags = [ "--server.http.listen-addr=0.0.0.0:12345" ];
  };

  users.groups.alloy = { };

  users.users.alloy = {
    isSystemUser = true;
    group = "alloy";
    extraGroups = [ "podman" ];
  };

  environment.etc."alloy/config.alloy" = {
    text = ''
      // Discover running Podman containers through Podman's Docker-compatible API.
      discovery.docker "containers" {
          host = "unix:///run/podman/podman.sock"
      }


      // Tail logs from discovered containers and forward them to Loki.
      loki.source.docker "containers" {
          host       = "unix:///run/podman/podman.sock"
          targets    = discovery.docker.containers.targets
          forward_to = [loki.write.default.receiver]
      }

      // Tail the host's systemd journal.
      loki.source.journal "journal" {
          max_age       = "12h"
          relabel_rules = loki.relabel.journal.rules
          forward_to    = [loki.write.default.receiver]
      }
                
      loki.relabel "journal" {
          forward_to = []

          rule {
              source_labels = ["__journal__systemd_unit"]
              target_label  = "unit"
          }
      }

      loki.write "default" {
          endpoint {
              url = "http://127.0.0.1:3100/loki/api/v1/push"
          }
      }
    '';
  };
}
