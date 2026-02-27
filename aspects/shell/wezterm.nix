_:
{
  flake.aspects.shell-wezterm.homeManager =
    { lib, ... }:
    {
        programs.wezterm = {
          enable = true;

          # System light/dark mode function
          # from https://wezfurlong.org/wezterm/config/lua/window/get_appearance.html
          extraConfig = lib.mkMerge [
            (lib.mkBefore (# lua
              ''
                local config = wezterm.config_builder()

                -- Theme
                local function scheme_for_appearance(appearance)
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

                config.color_scheme = 'Catppuccin Mocha'
                config.font = wezterm.font 'FiraCode Nerd Font Mono'
                -- https://github.com/wezterm/wezterm/issues/4962
                config.window_decorations = "INTEGRATED_BUTTONS | RESIZE"
                config.window_frame = {
                  border_left_width = '0.5cell',
                  border_right_width = '0.5cell',
                  border_bottom_height = '0.25cell',
                  border_top_height = '0.25cell',
                }
              ''))
            (lib.mkAfter ''
              return config
            '')
          ];
        };
    };
}
