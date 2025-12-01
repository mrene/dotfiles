{ lib, ... }:
{
  flake.nixosModules.all =
    { config, pkgs, ... }:
    let
      cfg = config.homelab.dyndns;
    in
    {
      options.homelab.dyndns = {
        enable = lib.mkEnableOption "Enable homelab cloudflare dns updates";
      };

      config = lib.mkIf cfg.enable {
        sops.secrets."cloudflare/token" = { };
        services.cloudflare-dyndns = {
          enable = true;
          apiTokenFile = config.sops.secrets."cloudflare/token".path;
          domains = [ "home.mathieurene.com" ];
          proxied = false;
          ipv4 = true;
          ipv6 = false;
        };
      };
    };
}
