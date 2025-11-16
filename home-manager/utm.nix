{inputs, pkgs, ...}: {
  imports = [
    ./modules
    inputs.self.homeManagerModules.neovim
  ];

  # Enable homelab modules
  homelab.shell.fish.enable = true;
  homelab.dev.git.enable = true;
  # homelab.editor.vim.enable = true;
  homelab.terminal.wezterm.enable = true;
  homelab.minimal.enable = true;
  homelab.gui.gnome.enable = true;
  homelab.gui.rofi.enable = true;

  home.packages = with pkgs; [
    fishPlugins.foreign-env
  ];

  home.stateVersion = "20.09";
}
