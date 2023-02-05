{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules/home-manager.nix
    ./modules/fish.nix
    ./modules/git.nix
    ./modules/neovim.nix

    ./modules/minimal.nix
    ./modules/common.nix
    ./modules/gnome.nix
    ./modules/hyprland.nix
    ./modules/rofi.nix
  ];

  home.stateVersion = "20.09";

  home.username = "mrene";
  home.homeDirectory = "/home/mrene";

  home.packages = with pkgs; [
    # NOTE node 16 needed for remote vsc server
    nodejs-16_x

    fishPlugins.foreign-env
  ];
}
