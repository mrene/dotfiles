{ config, common, pkgs, ... }:
{

  imports = [
    ./fonts.nix
  ];

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  environment.systemPackages = with pkgs; [
    google-chrome
    alacritty

    gnvim
    
    # The nixpkgs-unstable version fixes a bug around bad window dragging performance
    # https://github.com/wez/wezterm/issues/2530
    pkgs.pkgsUnstable.wezterm
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
