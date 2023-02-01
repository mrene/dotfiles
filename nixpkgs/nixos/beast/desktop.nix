{ config, common, pkgs, ... }:

{
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Fixes Wayland
  # https://discourse.nixos.org/t/fix-gdm-does-not-start-gnome-wayland-even-if-it-is-selected-by-default-starts-x11-instead/24498
  # services.xserver.desktopManager.defaultSession = "gnome";

  # services.xserver.desktopManager.cinnamon.enable = true;
  # services.xserver.windowManager.awesome.enable = true;

  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [
    gnome.gnome-tweaks
  ];

  services.mopidy = {
    enable = true;
    extensionPackages = with pkgs; [ 
      mopidy-mpd
      mopidy-ytmusic
      mopidy-soundcloud
      mopidy-iris
      mopidy-bandcamp
    ];
  };
}