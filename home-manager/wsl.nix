{pkgs, inputs, ...}: {
  imports = [
    ./modules/fish.nix
    ./modules/git.nix
    ./modules/jujutsu.nix
    ./modules/minimal.nix
    ./modules/common.nix
  ];

  home.packages = with pkgs; [
    fishPlugins.foreign-env
     inputs.app-nvim.packages.${pkgs.system}.default
  ];
  home.stateVersion = "20.09";
}
