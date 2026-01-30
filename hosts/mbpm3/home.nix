{ inputs, ... }:
{
  flake.modules.homeManager.mbpm3 =
    { pkgs, ... }:
    {
      # Aspects are now imported via home-manager.sharedModules in default.nix

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
      ];

      home.stateVersion = "25.11";
    };
}
