{lib, pkgs, ...}: {
  imports = [
    ./modules/fish.nix
    ./modules/git.nix
    ./modules/vim

    ./modules/minimal.nix
    ./modules/common.nix
    ./modules/gnome.nix
    ./modules/rofi
    ./modules/wezterm.nix
    ./modules/neofetch.nix
    ./modules/rgb
    ./modules/hctl.nix
  ];



  home.stateVersion = "20.09";

  home.username = "mrene";
  home.homeDirectory = "/home/mrene";

  home.packages = with pkgs; [
    fishPlugins.foreign-env
  ];

  home.sessionVariables = {
    NIX_LD_LIBRARY_PATH = lib.makeLibraryPath [
      pkgs.stdenv.cc.cc
    ];
    # NIX_LD = builtins.readFile "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
  };


  programs.fish.interactiveShellInit = ''
    set -x NIX_LD "${pkgs.stdenv.cc}/nix-support/dynamic-linker"
  '';
}
