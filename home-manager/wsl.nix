{pkgs, inputs, ...}: {
  imports = [
    ./modules
  ];

  # Enable homelab modules
  homelab.shell.fish.enable = true;
  homelab.dev.git.enable = true;
  homelab.dev.jujutsu.enable = true;
  homelab.minimal.enable = true;
  homelab.common.enable = true;

  home.packages = with pkgs; [
    fishPlugins.foreign-env
     inputs.self.packages.${pkgs.system}.nvim
  ];
  home.stateVersion = "20.09";
}
