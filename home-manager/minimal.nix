{...}:
# Minimal home configuration to apply to random machines
{
  imports = [
    ./modules
  ];

  # Enable homelab modules
  homelab.shell.fish.enable = true;
  homelab.dev.git.enable = true;
  homelab.editor.vim.enable = true;
  homelab.minimal.enable = true;

  home.stateVersion = "20.09";

  home.username = "mrene";
  home.homeDirectory = "/home/mrene";
}
