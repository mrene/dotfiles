{ lib, ... }:
{
  flake.nixosModules.all =
    { config, pkgs, ... }:
    let
      cfg = config.homelab.kanidm;
    in
    {
      options.homelab.kanidm = {
        enable = lib.mkEnableOption "Enable homelab kanidm configuration";
        domain = lib.mkOption {
          type = lib.types.str;
          default = "id.mathieurene.com";
          description = "The domain to use for the service";
        };
      };

      config = lib.mkIf cfg.enable {
        sops.secrets = {
          # "attic/hs256_secret" = {};
        };

        services.kanidm = {
          enableServer = true;
          serverSettings = {
            domain = "id.mathieurene.com";
            origin = "https://id.mathieurene.com";
          };
          clientSettings.uri = "https://id.mathieurene.com";
          provision = {
            enable = true;
            persons.mrene.displayName = "Mathieu";
            persons.sara.displayName = "Sara";
          };
        };

        services.caddy.virtualHosts."${cfg.domain}" = lib.mkIf config.services.caddy.enable {
          extraConfig = ''
            reverse_proxy http://localhost:8080
          '';
        };
      };
    };
}
