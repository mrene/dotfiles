{lib, pkgs, inputs, ...}: {
  imports = [
    ./modules
  ];

  # Enable homelab modules
  homelab.shell.fish.enable = true;
  homelab.dev.git.enable = true;
  homelab.dev.jujutsu.enable = true;
  # homelab.editor.vim.enable = true; # Commented out like before
  homelab.minimal.enable = true;
  homelab.common.enable = true;
  homelab.gui.gnome.enable = true;
  homelab.gui.rofi.enable = true;
  homelab.terminal.wezterm.enable = true;
  homelab.terminal.zellij.enable = true;
  homelab.system.neofetch.enable = true;

  programs.claude-code = {
    enable = true;
  };

  home.packages = let 
    notify = pkgs.writeShellApplication {
      name = "notify";
      runtimeInputs = [ pkgs.libnotify ];
      text = ''
        notify-send "$@"
      '';
    };
    in [
      pkgs.fishPlugins.foreign-env
      inputs.self.packages.${pkgs.system}.nvim
      notify
    ]; 

  home.stateVersion = "20.09";

  home.username = "mrene";
  home.homeDirectory = "/home/mrene";

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
