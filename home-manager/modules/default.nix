{
  # Import all home-manager modules as flake-parts modules
  # Each module contributes to flake.modules.homeManager.all (merged by flake-parts)

  imports = [
    # Core modules
    ./minimal.nix
    ./common.nix

    # Shell and terminal
    ./fish.nix
    ./wezterm.nix
    ./zellij.nix

    # Development tools
    ./git.nix
    ./jujutsu.nix
    # ./vim

    # System utilities
    ./ssh.nix
    ./neofetch.nix
    ./rgb

    # GUI applications
    ./gnome.nix
    ./rofi
    ./hyprland

    # Tools
    ./claude
    ./jira
  ];
}
