{ config, common, pkgs, ... }:

{
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  # services.xserver.desktopManager.cinnamon.enable = true;
  # services.xserver.windowManager.awesome.enable = true;

  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [
    gnome.gnome-tweaks
  ];
}