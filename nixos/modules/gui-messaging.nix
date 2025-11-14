{ lib, config, pkgs, ... }:

let
  cfg = config.homelab.gui.messaging;
in
{
  options.homelab.gui.messaging = {
    enable = lib.mkEnableOption "Enable homelab messaging applications (Slack, Discord, Element)";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      slack
      discord
      element-desktop
    ];
  };
}
