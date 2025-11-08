{
  lib,
  config,
  pkgs,
  inputs ? {},
  ...
}:
let
  cfg = config.homelab.gui.hyprland;
in
{
  imports = lib.optionals (inputs ? hyprland) [
    inputs.hyprland.homeManagerModules.default
  ];

  options.homelab.gui.hyprland = {
    enable = lib.mkEnableOption "Enable Hyprland Wayland compositor";
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = builtins.readFile ./hyprland.conf;
  };

  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
  };

    home.packages = with pkgs; [
      kitty
      wofi
    ];
  };
}
