{ pkgs, ... }:

{
  programs.wezterm = {
    enable = true;

    # The nixpkgs-unstable version fixes a bug around bad window dragging performance
    # https://github.com/wez/wezterm/issues/2530
    package = pkgs.pkgsUnstable.wezterm;
    extraConfig = ''
      return {
        color_scheme = "nordfox",
        window_decorations = "RESIZE",

        window_frame = {
          active_titlebar_bg = '#3b4252',
          inactive_titlebar_bg = '#3b4252',
        },
      }
    '';
  };
}