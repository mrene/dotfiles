_: {
  flake.modules.nixos.desktop-gui =
    { pkgs, ... }:
    {
      services.displayManager.gdm = {
        enable = true;
        autoSuspend = false;
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
}
