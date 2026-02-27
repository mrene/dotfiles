_:
{
  flake.aspects.shell-workmux.homeManager =
    { ... }:
    {
        programs.wezterm.extraConfig = # lua
          ''
            -- workmux: connect to unix mux server for consistent env vars across panes
            config.default_gui_startup_args = { 'connect', 'unix' }
            config.unix_domains = {
              { name = 'unix' },
            }

            -- workmux: cross-workspace navigation from dashboard
            wezterm.on('user-var-changed', function(window, pane, name, value)
              if name == 'workmux-switch-pane' then
                local data = wezterm.json_parse(value)
                window:perform_action(
                  wezterm.action.SwitchToWorkspace({ name = data.workspace }),
                  pane
                )
                wezterm.time.call_after(0.1, function()
                  for _, win in ipairs(wezterm.mux.all_windows()) do
                    for _, tab in ipairs(win:tabs()) do
                      if tab:get_title() == data.tab_title then
                        tab:activate()
                        local panes = tab:panes()
                        if #panes > 0 then panes[1]:activate() end
                        return
                      end
                    end
                  end
                end)
              end
            end)

            -- workmux: spawn tabs in mux server domain, not GUI domain
            config.keys = {
              { key = 't', mods = 'SUPER', action = wezterm.action.SpawnTab('CurrentPaneDomain') },
            }
          '';
    };
}
