{inputs, pkgs, ...}: {
  imports = [
    ./modules
     inputs.self.homeManagerModules.neovim
  ];

  homelab.shell.fish.enable = true;
  homelab.dev.git.enable = true;
  homelab.minimal.enable = true;

  home.packages = with pkgs; [
    fishPlugins.foreign-env
  ];

  home.stateVersion = "20.09";
}
