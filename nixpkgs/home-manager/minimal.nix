{ config, lib, pkgs, ... }:

# Minimal home configuration to apply to random machines 
{
  imports = [
    ./modules/home-manager.nix
    ./modules/fish.nix
    ./modules/git.nix
    ./modules/neovim.nix
    
    ./modules/minimal.nix
  ];

  home.stateVersion = "20.09";

  home.username = "mrene";
  home.homeDirectory = "/home/mrene";
}
