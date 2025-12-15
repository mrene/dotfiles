{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.homelab.terminal.wezterm;
in
{
  options.homelab.terminal.wezterm = {
    enable = lib.mkEnableOption "Enable wezterm terminal emulator";
  };

  config = lib.mkIf cfg.enable {
    programs.wezterm = {
    enable = true;

    # System light/dark mode function
    # from https://wezfurlong.org/wezterm/config/lua/window/get_appearance.html
    extraConfig = #lua
    ''
      function scheme_for_appearance(appearance)
          if appearance:find 'Dark' then
            return 'Catppuccin Mocha'
          else
            return 'Catppuccin Latte'
          end
        end

        wezterm.on('window-config-reloaded', function(window, pane)
          local overrides = window:get_config_overrides() or {}
          local appearance = window:get_appearance()
          local scheme = scheme_for_appearance(appearance)
          if overrides.color_scheme ~= scheme then
            overrides.color_scheme = scheme
            window:set_config_overrides(overrides)
          end
        end)

        return {
          color_scheme = 'Catppuccin Mocha',
          font = wezterm.font 'FiraCode Nerd Font Mono',
          -- https://github.com/wezterm/wezterm/issues/4962
          window_decorations = "INTEGRATED_BUTTONS | RESIZE",
          window_frame = {
            border_left_width = '0.5cell',
            border_right_width = '0.5cell',
            border_bottom_height = '0.25cell',
            border_top_height = '0.25cell',
          },
        }
    '';
    };
  };
}
