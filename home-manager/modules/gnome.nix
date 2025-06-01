{lib, pkgs, ...}: {
  # ...
  gtk = {
    enable = true;

    iconTheme = {
      name = "whitesur";
      package = pkgs.whitesur-icon-theme;
    };

    theme = {
      name = "Catppuccin-Mocha-Standard-Pink-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = ["pink"];
        variant = "mocha";
      };
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

  home.sessionVariables.GTK_THEME = "Catppuccin-Mocha-Standard-Pink-Dark";

  dconf.settings = with lib.gvariant; {
    # ...
    "org/gnome/shell" = {
      disable-user-extensions = false;

      favorite-apps = [
        "org.wezfurlong.wezterm.desktop"
        "logseq.desktop"
        "slack.desktop"
        "google-chrome.desktop"
      ];

      # `gnome-extensions list` for a list
      enabled-extensions = [
        "tilingshell@ferrarodomenico.com"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "trayIconsReloaded@selfmade.pl"
        "Vitals@CoreCoding.com"
        "dash-to-panel@jderose9.github.com"
        "sound-output-device-chooser@kgshank.net"
        "space-bar@luchrioh"
        "disable-workspace-animation@ethnarque"
        "alttab-mod@leleat-on-github"
      ];
    };

    "org/gnome/mutter" = {
      workspaces-only-on-primary = false;
    };

    "org/gnome/shell/extensions/tilingshell" = {
      inner-gaps = mkUint32 2;
      outer-gaps = mkUint32 0;

      move-window-right = ["<Super>Right"];
      move-window-left = ["<Super>Left"];
      move-window-up = ["<Super>Up"];
      move-window-down = ["<Super>Down"];

      span-window-right = ["<Shift><Super>Right"];
      span-window-left = ["<Shift><Super>Left"];
      span-window-up = ["<Shift><Super>Up"];
      span-window-down = ["<Shift><Super>Down"];

      focus-window-right = ["<Control><Super>Right"];
      focus-window-left = ["<Control><Super>Left"];
      focus-window-up = ["<Control><Super>Up"];
      focus-window-down = ["<Control><Super>Down"];
    };

    "org/gnome/shell/extensions/altTab-mod" = {
      current-workspace-only = true;
      current-workspace-only-window = true;
    };

    "org/gnome/shell/extensions/dash-to-panel" = {
      isolate-workspaces = true;
      group-apps = false;
      stockgs-keep-top-panel = true;
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "Catppuccin-Dark";
    };

    "org/gnome/desktop/interface/icon-theme" = {
      name = "WhiteSur-dark";
    };

    "org/gnome/desktop/interface/gtk-theme" = {
      name = "Catppuccin-Pink-Dark";
    };

    "org/gnome/shell/extensions/dash-to-panel" = {
      panel-sizes = ''{"0":32,"1":32}'';
      panel-positions = true;
      multi-monitors = true;
      dot-style-unfocused = "DOTS";
      dot-style-focused = "CILIORA";
      show-window-previews-timeout = 125;
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,close";
      theme = "Nordic";
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

    "org.gnome.settings-daemon.plugins.media-keys" = {
      screen-brightness-up = "<Super>Vol+";
      screen-brightness-down = "<Super>Vol-";
    };

    # Prevent auto-suspend
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
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
    gnomeExtensions.tiling-shell
    gnomeExtensions.disable-workspace-animation
    gnomeExtensions.alttab-mod
  ];
}
