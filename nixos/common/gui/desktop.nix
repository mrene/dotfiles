{pkgs, ...}: {
  services.xserver.displayManager.gdm = {
    enable = true;
    autoSuspend = false;
    wayland = false;
  };
  services.xserver.desktopManager.gnome.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };

  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [
    gnome.gnome-tweaks
  ];
}
