{
  # All home-manager modules with homelab.* namespace
  # Enable modules by setting homelab.<category>.<name>.enable = true in host configs

  imports = [
    # Core modules
    ./minimal.nix        # homelab.minimal.enable
    ./common.nix         # homelab.common.enable

    # Shell and terminal
    ./fish.nix           # homelab.shell.fish.enable
    ./wezterm.nix        # homelab.terminal.wezterm.enable
    ./zellij.nix         # homelab.terminal.zellij.enable

    # Development tools
    ./git.nix            # homelab.dev.git.enable
    ./jujutsu.nix        # homelab.dev.jujutsu.enable
    ./vim               # homelab.editor.vim.enable

    # System utilities
    ./ssh.nix            # homelab.system.ssh.enable
    ./neofetch.nix       # homelab.system.neofetch.enable
    ./rgb               # homelab.system.rgb.enable

    # GUI applications
    ./gnome.nix          # homelab.gui.gnome.enable
    ./rofi              # homelab.gui.rofi.enable
    ./hyprland          # homelab.gui.hyprland.enable

    # Tools
    ./claude            # homelab.tools.claude.enable
    ./jira              # homelab.tools.jira.enable
  ];
}
