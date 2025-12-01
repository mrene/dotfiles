{ lib, ... }:
{
  flake.nixosModules.all =
    { config, pkgs, ... }:
    let
      cfg = config.homelab.gui.desktop;
    in
    {
      options.homelab.gui.desktop = {
        enable = lib.mkEnableOption "Enable homelab GNOME desktop environment";
      };

      config = lib.mkIf cfg.enable {
        services.displayManager.gdm = {
          enable = true;
          autoSuspend = false;
          wayland = true;
        };
        services.desktopManager.gnome.enable = true;

        xdg.portal = {
          enable = true;
          wlr.enable = true;
        };

        programs.dconf.enable = true;
        environment.systemPackages = with pkgs; [
          gnome-tweaks
        ];
      };
    };
}
