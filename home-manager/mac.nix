{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./modules/fish.nix
    ./modules/git.nix
    ./modules/vim

    ./modules/minimal.nix
    ./modules/common.nix
    ./modules/wezterm.nix
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

  programs.ssh.extraConfig = "IdentityAgent /Users/mrene/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";

  home.packages = with pkgs; [
    inputs.minidsp.packages.${system}.default
    pathfind
  ];

  home.stateVersion = "20.09";
}
