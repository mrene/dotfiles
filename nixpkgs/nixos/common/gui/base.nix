{ config, common, pkgs, ... }:
{

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  environment.systemPackages = with pkgs; [
    google-chrome
    alacritty
    wezterm
    flameshot # Screenshot software
    simplescreenrecorder

    _1password-gui
    keybase
    keybase-gui
  ];

  programs.firefox = {
    enable = true;
    # TODO: Add extensions
  };
}
