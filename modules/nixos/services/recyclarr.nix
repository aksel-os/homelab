{ config, self, ... }:

let
  inherit (config.sops) secrets;

in
{
  sops.secrets = {
    "radarr/api_key".sopsFile = "${self}/secrets/services/radarr.yaml";
    "sonarr/api_key".sopsFile = "${self}/secrets/services/sonarr.yaml";
    "sonani/api_key".sopsFile = "${self}/secrets/services/sonarr.yaml";
  };

  services.recyclarr = {
    enable = true;
    configuration = {
      radarr = {
        radarr-main = {
          api_key._secret = secrets."radarr/api_key".path;
          base_url = "http://localhost:7878";
          delete_old_custom_formats = true;

          quality_profiles = [
            {
              trash_id = "d1d67249d3890e49bc12e275d989a7e9"; # HD Blueray + WEB
              reset_unmatched_scores.enabled = true;
            }
            {
              trash_id = "64fb5f9858489bdac2af690e27c8f42f"; # UHD Blueray + WEB
              reset_unmatched_scores.enabled = true;
            }
            {
              trash_id = "9ca12ea80aa55ef916e3751f4b874151"; # Remux + WEB 1080p
              reset_unmatched_scores.enabled = true;
            }
            {
              trash_id = "fd161a61e3ab826d3a22d53f935696dd"; # Remux + WEB 2160p
              reset_unmatched_scores.enabled = true;
            }
          ];

          media_naming = {
            folder = "jellyfin-tmdb";

            movie = {
              rename = true;
              standard = "jellyfin-tmdb";
            };
          };
        };
      };

      sonarr = {
        sonarr-main = {
          api_key._secret = secrets."sonarr/api_key".path;
          base_url = "http://localhost:8989";
          delete_old_custom_formats = true;

          quality_profiles = [
            {
              trash_id = "fe9470e577c300a5ad9a3274f6d1cdf2"; # Remux + WEB 1080p
              reset_unmatched_scores.enabled = true;
            }
            {
              trash_id = "76a5053bdb2d1e4a8f16a69a37d46c12"; # Remux + WEB 2160p
              reset_unmatched_scores.enabled = true;
            }
          ];

          media_naming = {
            episodes = {
              rename = true;
              standard = "default";
              anime = "default";
            };
          };
        };

        sonarr-anime = {
          api_key._secret = secrets."sonani/api_key".path;
          base_url = "http://localhost:9898";
          delete_old_custom_formats = true;

          quality_profiles = [
            {
              trash_id = "20e0fc959f1f1704bed501f23bdae76f"; # Anime Remux-1080p
              reset_unmatched_scores.enabled = true;
            }
          ];

          media_naming = {
            episodes = {
              rename = true;
              standard = "default";
              anime = "default";
            };
          };
        };
      };
    };
  };
}
