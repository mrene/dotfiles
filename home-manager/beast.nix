{lib, pkgs, inputs, ...}: {
  imports = [
    ./modules/fish.nix
    ./modules/git.nix
    ./modules/jujutsu.nix
    # ./modules/vim

    ./modules/minimal.nix
    ./modules/common.nix
    ./modules/gnome.nix
    ./modules/rofi
    ./modules/wezterm.nix
    ./modules/neofetch.nix

    inputs.claude-code.homeManagerModules.claude-code
  ];

  programs.claude-code = {
    enable = true;
  };

  home.stateVersion = "20.09";

  home.username = "mrene";
  home.homeDirectory = "/home/mrene";

  home.packages = with pkgs; [
    fishPlugins.foreign-env
    inputs.app-nvim.packages.${pkgs.system}.default
  ];

  home.sessionVariables = {
    NIX_LD_LIBRARY_PATH = lib.makeLibraryPath [
      pkgs.stdenv.cc.cc
    ];
    # NIX_LD = builtins.readFile "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
  };

  programs.fish.interactiveShellInit = ''
    set -x NIX_LD (cat "${pkgs.stdenv.cc}/nix-support/dynamic-linker")
  '';
}
