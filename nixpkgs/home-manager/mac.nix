{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules/home-manager.nix
    ./modules/fish.nix
    ./modules/git.nix
    ./modules/neovim.nix

    ./modules/minimal.nix
    ./modules/common.nix
  ];

  home.username = "mrene";
  home.homeDirectory = "/Users/mrene";

  programs.fish.interactiveShellInit = ''
    set -x SSH_AUTH_SOCK "$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";

    set -x PATH $PATH "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

    # nix-darwin binaries
    set -x PATH $PATH "/run/current-system/sw/bin/"

    # `/usr/local/bin` is needed for biometric-support in `op` 1Password CLI
    set -x PATH $PATH /usr/local/bin 
  '';

  home.packages = with pkgs; [
    minidsp
    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/data/fonts/nerdfonts/default.nix
    # nerdfonts
  ];

  home.stateVersion = "20.09";
}
