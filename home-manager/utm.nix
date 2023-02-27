{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules/fish.nix
    ./modules/git.nix
    ./modules/vim

    ./modules/minimal.nix
    ./modules/gnome.nix
    ./modules/rofi
  ];

  home.packages = with pkgs; [
    # NOTE node 16 needed for remote vsc server
    nodejs-16_x

    fishPlugins.foreign-env
  ];

  home.stateVersion = "20.09";
}
