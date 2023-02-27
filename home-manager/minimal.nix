{ config, lib, pkgs, ... }:

# Minimal home configuration to apply to random machines 
{
  imports = [
    ./modules/fish.nix
    ./modules/git.nix
    ./modules/vim
    ./modules/minimal.nix
  ];

  home.stateVersion = "20.09";

  home.username = "mrene";
  home.homeDirectory = "/home/mrene";
}
