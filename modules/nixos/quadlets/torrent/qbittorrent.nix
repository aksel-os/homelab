{ config, ... }:

let
  inherit (config.virtualisation.quadlet) pods;

in
{
  virtualisation.quadlet.containers.qbittorrent = {
    containerConfig = {
      image = "docker.io/linuxserver/qbittorrent:latest";

      pod = pods.torrent.ref;
      startWithPod = true;

      environments = {
        TZ = "Europe/Oslo";
        WEBUI_PORT = "8080";
        PUID = "1000";
        GUID = "1000";
      };

      volumes = [
        "/var/lib/qbittorrent/config:/config"
        "/srv/downloads:/downloads"
      ];
    };

    unitConfig = {
      After = [ "gluetun.service" ];
      Requires = [ "gluetun.service" ];
    };
  };
}
