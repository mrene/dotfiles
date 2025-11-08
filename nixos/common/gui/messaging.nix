# REFACTOR PLAN: This file will become:
#   - homelab.gui.messaging.enable (Slack, Discord, Element)
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    slack
    discord
    element-desktop
  ];
}
