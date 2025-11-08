{pkgs, ...}: {
  imports = [
    ./modules
  ];

  # Enable homelab modules
  homelab.shell.fish.enable = true;
  homelab.dev.git.enable = true;
  homelab.editor.vim.enable = true;
  homelab.minimal.enable = true;
  homelab.common.enable = true;
  homelab.system.neofetch.enable = true;

  home.stateVersion = "20.09";

  home.username = "mrene";
  home.homeDirectory = "/home/mrene";

  home.packages = with pkgs; [
    fishPlugins.foreign-env
  ];
}
