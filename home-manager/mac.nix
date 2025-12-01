{
  pkgs,
  inputs,
  ...
}:
{

  # Enable homelab modules
  homelab.shell.fish.enable = true;
  homelab.dev.git.enable = true;
  # homelab.editor.vim.enable = true; # Commented out like before
  homelab.minimal.enable = true;
  homelab.common.enable = true;
  homelab.terminal.wezterm.enable = true;
  homelab.dev.jujutsu.enable = true;

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
    inputs.mrene-nur.packages.${system}.pathfind
    inputs.self.packages.${pkgs.system}.nvim
  ];

  home.stateVersion = "20.09";
}
