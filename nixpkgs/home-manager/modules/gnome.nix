{ pkgs, ... }:

{
  # ...
  gtk = {
    enable = true;

    iconTheme = {
      name = "whitesur";
      package = pkgs.whitesur-icon-theme;
    };

    theme = {
      name = "whitesur";
      package = pkgs.whitesur-gtk-theme;
    };

    cursorTheme = {
      name = "Numix-Cursor";
      package = pkgs.numix-cursor-theme;
    };

    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };

    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };

  home.sessionVariables.GTK_THEME = "palenight";

  dconf.settings = {
    # ...
    "org/gnome/shell" = {
      disable-user-extensions = false;

      # `gnome-extensions list` for a list
      enabled-extensions = [
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "trayIconsReloaded@selfmade.pl"
        "Vitals@CoreCoding.com"
        "dash-to-panel@jderose9.github.com"
        "sound-output-device-chooser@kgshank.net"
        "space-bar@luchrioh"
      ];
    };
    "org/gnome/shell/extensions/user-theme" = {
      name = "WhiteSur-Dark";
    };

    "org/gnome/desktop/interface/icon-theme" = {
      name = "WhiteSur-dark";
    };

    "org/gnome/desktop/interface/gtk-theme" = {
      name = "WhiteSur-Dark";
    };

    "org/gnome/shell/extensions/dash-to-panel" = {
      panel-sizes = ''{"0":32,"1":32}'';
      panel-positions = true;
      multi-monitors = true;
      dot-style-unfocused = "DOTS";
      dot-style-focused = "CILIORA";
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,close";
    };

    "org/gnome/desktop/background" = {
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-l.svg";
      picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-d.svg";
      primary-color = "#241f31";
    };

    "org/gnome/desktop/screensaver" = {
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-l.svg";
      picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-d.svg";
      primary-color = "#241f31";
    };
  };

  home.packages = with pkgs; [
    # ...
    gnomeExtensions.user-themes
    gnomeExtensions.tray-icons-reloaded
    gnomeExtensions.vitals
    gnomeExtensions.dash-to-panel
    gnomeExtensions.sound-output-device-chooser
    gnomeExtensions.space-bar

    palenight-theme
    whitesur-gtk-theme
    whitesur-icon-theme
  ];
}