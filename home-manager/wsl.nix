{ pkgs, inputs, ... }:
{

  # Enable homelab modules
  homelab.shell.fish.enable = true;
  homelab.dev.git.enable = true;
  homelab.dev.jujutsu.enable = true;
  homelab.minimal.enable = true;
  homelab.common.enable = true;

  home.packages = with pkgs; [
    fishPlugins.foreign-env
  ];
  home.stateVersion = "20.09";
}
