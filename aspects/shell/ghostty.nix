_:
{
  flake.aspects.shell-ghostty.homeManager =
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

            # Custom CSI sequences for tmux splits. Ghostty's legacy keyboard
            # mode doesn't encode shifted-punctuation chords with multiple
            # modifiers, so emit our own. tmux user-keys binds these.
            # Format mimics kitty CSI-u: <keycode>;<mod>u. Keycode is the
            # unshifted ASCII; mod 8 = shift(1)+alt(2)+ctrl(4)+bias(1).
            "ctrl+shift+alt+'=csi:39;8u"
            "ctrl+shift+alt+5=csi:53;8u"
          ];
        };
      };
    };
}
