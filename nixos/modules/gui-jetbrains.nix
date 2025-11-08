{ lib, config, pkgs, ... }:

let
  cfg = config.homelab.gui.jetbrains;

  ides = with pkgs; [
    jetbrains.webstorm
    jetbrains.goland
    jetbrains.pycharm-professional
    jetbrains.datagrip
    jetbrains.clion
  ];
in
{
  options.homelab.gui.jetbrains = {
    enable = lib.mkEnableOption "Enable homelab JetBrains IDEs";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      [
        jetbrains.datagrip
      ]
      ++ builtins.map (ide: (jetbrains.plugins.addPlugins ide ["ideavim"])) ides;
  };
}
