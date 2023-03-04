{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./modules/fish.nix
    ./modules/git.nix
    ./modules/vim

    ./modules/minimal.nix
    ./modules/common.nix
    ./modules/gnome.nix
    #./modules/hyprland
    ./modules/rofi
    ./modules/wezterm.nix
    ./modules/neofetch.nix
    ./modules/rgb
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
