{
  flake.modules.homeManager.shell-extras =
    { ... }:
    {
      programs.ghostty = {
        enable = true;
        enableFishIntegration = true;

        settings = {
          font-family = "FiraCode Nerd Font Mono";
          theme = "catppuccin-mocha";

          keybind = [
            # Free Ctrl+Shift+Left/Right so tmux pane navigation reaches inside.
            "ctrl+shift+arrow_left=unbind"
            "ctrl+shift+arrow_right=unbind"

            # Custom CSI sequences for tmux splits. Final byte 'z' (not 'u'
            # or '~') is critical: tmux's tty_keys_extended_key parser only
            # accepts u/~ as CSI-u terminators, so 'z' falls through to the
            # user-keys lookup. With 'u', tmux would decode \e[39;8u as
            # Ctrl+Alt+Shift+' then re-encode to \e' (dropping Shift+Ctrl
            # per input_key_vt10x), bypassing user-keys entirely.
            "ctrl+shift+alt+'=text:\\x1b[39;8z"
            "ctrl+shift+alt+5=text:\\x1b[53;8z"
          ];
        };
      };
    };
}
