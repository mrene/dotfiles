# REFACTOR PLAN: This file will become:
#   - homelab.gui.jetbrains.enable (JetBrains IDEs)
{pkgs, ...}: let
  ides = with pkgs; [
    jetbrains.webstorm
    jetbrains.goland
    jetbrains.pycharm-professional
    jetbrains.datagrip
    jetbrains.clion
  ];
in {
  environment.systemPackages = with pkgs;
    [
      jetbrains.datagrip
    ]
    ++ builtins.map (ide: (jetbrains.plugins.addPlugins ide ["ideavim"])) ides;
}
