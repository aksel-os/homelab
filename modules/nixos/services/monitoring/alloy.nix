{
  services.alloy = {
    enable = true;

    extraFlags = [ "--server.http.listen-addr=127.0.0.1:12345" ];
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
          relabel_rules = loki.relabel.containers.rules
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

      loki.relabel "containers" {
          forward_to = []

          rule {
              source_labels = ["__meta_docker_container_name"]
              regex         = "/?(.*)"
              target_label  = "container"
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
