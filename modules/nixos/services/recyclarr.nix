{ config, self, ... }:

let
  inherit (config.sops) secrets;

in
{
  sops.secrets = {
    "radarr/api_key".sopsFile = "${self}/secrets/services/radarr.yaml";
    "sonarr/api_key".sopsFile = "${self}/secrets/services/sonarr.yaml";
  };

  services.recyclarr = {
    enable = true;
    configuration = {
      radarr = {
        radarr-main = {
          api_key._secret = secrets."radarr/api_key".path;
          base_url = "http://localhost:7878";
        };
      };

      sonarr = {
        sonarr-main = {
          api_key._secret = secrets."sonarr/api_key".path;
          base_url = "http://localhost:8989";
        };
      };
    };
  };
}
