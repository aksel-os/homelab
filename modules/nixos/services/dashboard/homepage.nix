{ config, ... }:

let
  inherit (config.sops) templates;

in
{
  sops.templates."homepage.env" = {
    content = ''
      HOMEPAGE_VAR_JELLYFIN_API_KEY=${config.sops.placeholder."jellyfin/api_key"}
      HOMEPAGE_VAR_SONARR_API_KEY=${config.sops.placeholder."sonarr/api_key"}
      HOMEPAGE_VAR_RADARR_API_KEY=${config.sops.placeholder."radarr/api_key"}
    '';
    restartUnits = [ "homepage.service" ];
  };

  services.homepage-dashboard = {
    enable = true;
    environmentFiles = [ templates."homepage.env".path ];

    settings = {
      title = "Homelab";

      theme = "dark";
      color = "slate";

      headerStyle = "clean";
      statusStyle = "dot";

      disableIndexing = true;
      hideErrors = true;

      layout = {
        media = {
          style = "row";
          columns = 4;
        };

        arr = {
          style = "row";
          columns = 4;
        };

        downloads = {
          style = "row";
          columns = 4;
        };

        books = {
          style = "row";
          columns = 4;
        };

        infra = {
          style = "row";
          columns = 4;
        };
      };
    };

    services = [
      {
        media = [
          {
            Jellyfin = {
              icon = "jellyfin.png";
              href = "http://localhost:8069";
              description = "Movies & TV";
              siteMonitor = "https://jellyfin.home.arpa";

              widget = {
                type = "jellyfin";
                url = "http://localhost:8069";
                key = "{{HOMEPAGE_VAR_JELLYFIN_API_KEY}}";
              };
            };
          }

          {
            Audiobookshelf = {
              icon = "audiobookshelf.png";
              href = "http://localhost:13378";
              description = "Audiobooks & podcasts";
              siteMonitor = "https://audiobookshelf.home.arpa";

              widget = {
                type = "audiobookshelf";
                url = "http://localhost:13378";
                key = "{{HOMEPAGE_VAR_AUDIOBOOKSHELF_API_KEY}}";
              };
            };
          }

          # {
          #   Immich = {
          #     icon = "immich.png";
          #     href = "http://localhost:2283";
          #     description = "Photos & videos";
          #     siteMonitor = "https://immich.home.arpa";
          #   };
          # }

          {
            Shoko = {
              icon = "shoko.png";
              href = "http://localhost:8111";
              description = "Anime metadata";
              siteMonitor = "http://localhost:8111";
            };
          }
        ];
      }
    ];

    widgets = [ ];
    docker = { };
  };
}
