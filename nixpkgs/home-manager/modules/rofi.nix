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
      command = "rofi -modi window,drun,top -show window -show-icons";
      name = "rofi";
    };
  };
}