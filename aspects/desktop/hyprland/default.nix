{ lib, inputs, ... }:
{
  flake.aspects.desktop-hyprland.homeManager =
    { pkgs, ... }:
    {
      imports = lib.optionals (inputs ? hyprland) [
        inputs.hyprland.homeManagerModules.default
      ];
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
