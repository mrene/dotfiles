{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules/home-manager.nix
    ./modules/fish.nix
    ./modules/git.nix
    ./modules/neovim.nix

    ./modules/minimal.nix
    ./modules/gnome.nix
    ./modules/hyprland.nix
    ./modules/rofi.nix
  ];

  home.packages = with pkgs; [
    # NOTE node 16 needed for remote vsc server
    nodejs-16_x

    fishPlugins.foreign-env
  ];

  home.stateVersion = "20.09";
}
