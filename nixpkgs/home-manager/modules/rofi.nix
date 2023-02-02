{ pkgs, config, ... }:

{
  programs.rofi = {
    enable = true;
    plugins = with pkgs; [
      rofi-top
      rofimoji
    ];
    theme = "${./rofi}/theme.rasi";
  };

  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Control><Alt>space";
      command = "rofi -modes combi,top -show combi -combi-modes \"window,drun\"  -show-icons -dpi 175";
      # command = "rofi -modi window,drun,top -show window -show-icons -dpi 175";
      name = "rofi";
    };
  };

  home.file."${config.xdg.configHome}/rofi/config.top" = {
    # Sort by CPU, order Descending
    text = ''
      [general]
      sorting=4
      ordering=1
    '';
  };
}