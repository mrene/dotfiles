{ lib, pkgs, ... }:
{
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
        accents = [ "pink" ];
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

      favorite-apps = [
        "org.wezfurlong.wezterm.desktop"
        "Logseq.desktop"
        "slack.desktop"
        "google-chrome.desktop"
      ];

      # should be managed by programs.gnome-shells.extensions
      # disable-user-extensions = false;
      # `gnome-extensions list` for a list
      # enabled-extensions = [
      #   "tilingshell@ferrarodomenico.com"
      #   "user-theme@gnome-shell-extensions.gcampax.github.com"
      #   "trayIconsReloaded@selfmade.pl"
      #   "Vitals@CoreCoding.com"
      #   "dash-to-panel@jderose9.github.com"
      #   "sound-output-device-chooser@kgshank.net"
      #   "space-bar@luchrioh"
      #   "disable-workspace-animation@ethnarque"
      #   "alttab-mod@leleat-on-github"
      #   "smart-home@chlumskyvaclav.gmail.com"
      # ];
    };

    # Disable middle click paste
    "org/gnome/desktop/interface" = {
      gtk-enable-primary-paste = false;
    };

    "org/gnome/mutter" = {
      workspaces-only-on-primary = false;
      overlay-key = "";
    };

    "org/gnome/desktop/wm/keybindings" = {
      switch-to-workspace-1 = [ "Tools" ];
      switch-to-workspace-2 = [ "Launch5" ];
      switch-to-workspace-3 = [ "Launch6" ];
      switch-to-workspace-4 = [ "Launch7" ];
    };

    "org/gnome/shell/extensions/tilingshell" = {
      inner-gaps = mkUint32 2;
      outer-gaps = mkUint32 0;

      move-window-right = [ "<Super>Right" ];
      move-window-left = [ "<Super>Left" ];
      move-window-up = [ "<Super>Up" ];
      move-window-down = [ "<Super>Down" ];

      span-window-right = [ "<Shift><Super>Right" ];
      span-window-left = [ "<Shift><Super>Left" ];
      span-window-up = [ "<Shift><Super>Up" ];
      span-window-down = [ "<Shift><Super>Down" ];

      focus-window-right = [ "<Control><Super>Right" ];
      focus-window-left = [ "<Control><Super>Left" ];
      focus-window-up = [ "<Control><Super>Up" ];
      focus-window-down = [ "<Control><Super>Down" ];
    };

    #"org/gnome/shell/extensions/altTab-mod" = {
    #  current-workspace-only = true;
    #  current-workspace-only-window = true;
    #};

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
      control-center-static = [ "" ];
    };

    # Prevent auto-suspend
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };

    "org/gnome/shell/extensions/space-bar/behavior" = {
      always-show-numbers = true;
    };

    "org/gnome/shell/extensions/advanced-alt-tab-window-switcher" = {
      app-switcher-popup-sorting = mkUint32 1;
      switcher-popup-timeout = mkUint32 0;
      switcher-popup-preview-selected = mkUint32 2;
      switcher-popup-position = mkUint32 3;
      super-key-mode = mkUint32 1;
      enable-super = false;
      hot-edge-mode = mkUint32 0;
      switcher-popup-ext-app-stable = false;
      animation-time-factor = mkUint32 100;
      switcher-ws-thumbnails = 1;
      win-switcher-popup-filter = 2;
      switcher-popup-shift-hotkeys = true;
      app-switcher-popup-filter = 2;
      app-switcher-popup-fav-apps = false;
      app-switcher-popup-include-show-apps-icon = false;
      app-switcher-popup-titles = false;
      app-switcher-popup-win-counter = true;
      app-switcher-popup-hide-win-counter-for-single-window = true;
    };

    # "org/gnome/shell/extensions/smart-home" = {
    #   "remember-opened-submenu" = true;
    #   "menu-selection" = {
    #     "http://tvpi_home-assistant" = {
    #       group = "office";
    #     };
    #     "smart-home-universal_smart-home-universal" = {
    #       group = "Office";
    #     };
    #   };
    # };
  };

  programs.gnome-shell = {
    enable = true;
    extensions = with pkgs; [
      { package = gnomeExtensions.user-themes; }
      { package = gnomeExtensions.tray-icons-reloaded; }
      { package = gnomeExtensions.vitals; }
      { package = gnomeExtensions.dash-to-panel; }
      { package = gnomeExtensions.sound-output-device-chooser; }
      { package = gnomeExtensions.space-bar; }
      { package = gnomeExtensions.tiling-shell; }
      { package = gnomeExtensions.disable-workspace-animation; }
      { package = gnomeExtensions.smart-home; }
      { package = gnomeExtensions.advanced-alttab-window-switcher; }
      { package = gnomeExtensions.set-monitor-ddc-brightnesscontrast-extra-dimming; }
      { package = gnomeExtensions.panel-date-format; }
    ];
  };
}
