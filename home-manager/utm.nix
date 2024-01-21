{pkgs, ...}: {
  imports = [
    ./modules/fish.nix
    ./modules/git.nix
    ./modules/vim
    ./modules/wezterm.nix

    ./modules/minimal.nix
    ./modules/gnome.nix
    ./modules/rofi
  ];

  home.packages = with pkgs; [
    fishPlugins.foreign-env
  ];

  home.stateVersion = "20.09";
}
