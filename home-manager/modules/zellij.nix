{ config, pkgs, ... }:

{
  programs.zellij = {
    enable = true;
    settings = {
      theme = "default";
      default_mode = "normal";
      keybinds = {
        normal = {
          "bind \"Ctrl b\"" = {
            SwitchToMode = "tmux";
          };
        };
        tmux = {
          "bind \"[\"" = {
            SwitchToMode = "Scroll";
          };
          "bind \"Ctrl b\"" = {
            Write = 2;
          };
          "bind \"\\\"\"" = {
            NewPane = "Down";
          };
          "bind \"%\"" = {
            NewPane = "Right";
          };
          "bind \"z\"" = {
            ToggleFocusFullscreen = {};
          };
          "bind \"c\"" = {
            NewTab = {};
          };
          "bind \",\"" = {
            SwitchToMode = "RenameTab";
            TabNameInput = 0;
          };
          "bind \"p\"" = {
            GoToPreviousTab = {};
          };
          "bind \"n\"" = {
            GoToNextTab = {};
          };
          "bind \"Left\"" = {
            MoveFocus = "Left";
          };
          "bind \"Right\"" = {
            MoveFocus = "Right";
          };
          "bind \"Up\"" = {
            MoveFocus = "Up";
          };
          "bind \"Down\"" = {
            MoveFocus = "Down";
          };
          "bind \"h\"" = {
            MoveFocus = "Left";
          };
          "bind \"l\"" = {
            MoveFocus = "Right";
          };
          "bind \"j\"" = {
            MoveFocus = "Down";
          };
          "bind \"k\"" = {
            MoveFocus = "Up";
          };
          "bind \"o\"" = {
            FocusNextPane = {};
          };
          "bind \"d\"" = {
            Detach = {};
          };
          "bind \"Space\"" = {
            NextSwapLayout = {};
          };
          "bind \"x\"" = {
            CloseFocus = {};
          };
        };
      };
    };
  };
}