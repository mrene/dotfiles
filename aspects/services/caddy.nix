{ lib, ... }:
{
  flake.aspects.services-caddy.nixos =
    { config, pkgs, ... }:
    let
      cfg = config.homelab.caddy;
    in
    {
      options.homelab.caddy = {
        enable = lib.mkEnableOption "Enable homelab caddy configuration";
      };

      config = lib.mkIf cfg.enable {
        services.caddy = {
          enable = true;
          email = "mathieu.rene@gmail.com";
        };

        networking.firewall.allowedTCPPorts = [ 443 ];
      };
    };
}
