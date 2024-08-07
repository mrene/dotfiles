{ lib, config, pkgs, inputs,  ... }:

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
      globalConfig = ''
        auto_https
      '';
    };

    networking.firewall.allowedTCPPorts = [ 443 ];
  };
}
