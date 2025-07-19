{ config, pkgs, ... }:

{
  programs.zellij = {
    enable = true;
    settings = {
      keybinds = {
        normal = {
          _props.clear-defaults = true;
          "bind \"Ctrl b\"" = {
            SwitchToMode = "tmux";
          };
        };
        tmux = {
          "bind \"1\"" = {
            GoToTab = 1;
            SwitchToMode = "Normal";
          };
          "bind \"2\"" = {
            GoToTab = 2;
            SwitchToMode = "Normal";
          };
          "bind \"3\"" = {
            GoToTab = 3;
            SwitchToMode = "Normal";
          };
          "bind \"4\"" = {
            GoToTab = 4;
            SwitchToMode = "Normal";
          };
          "bind \"5\"" = {
            GoToTab = 5;
            SwitchToMode = "Normal";
          };
          "bind \"6\"" = {
            GoToTab = 6;
            SwitchToMode = "Normal";
          };
          "bind \"7\"" = {
            GoToTab = 7;
            SwitchToMode = "Normal";
          };
          "bind \"8\"" = {
            GoToTab = 8;
            SwitchToMode = "Normal";
          };
          "bind \"9\"" = {
            GoToTab = 9;
            SwitchToMode = "Normal";
          };
          "bind \"e\"" = {
            EditScrollback = {};
            SwitchToMode = "Normal";
          };
          "bind \"m\"" = {
            SwitchToMode = "move";
          };
          "bind \"=\"" = {
            SwitchToMode = "resize";
          };
        };
      };
    };
  };
}