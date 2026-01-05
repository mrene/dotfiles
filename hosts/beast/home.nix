{ inputs, ... }:
{
  flake.modules.homeManager.beast =
    {
      lib,
      pkgs,
      inputs,
      ...
    }:
    {
      home.packages =
        let
          notify = pkgs.writeShellApplication {
            name = "notify";
            runtimeInputs = [ pkgs.libnotify ];
            text = ''
              notify-send "$@"
            '';
          };
        in
        [
          pkgs.fishPlugins.foreign-env
          notify
        ];

      home.stateVersion = "20.09";

      home.username = "mrene";
      home.homeDirectory = "/home/mrene";

      home.sessionVariables = {
        NIX_LD_LIBRARY_PATH = lib.makeLibraryPath [
          pkgs.stdenv.cc.cc
        ];
      };

      programs.fish.interactiveShellInit = ''
        set -x NIX_LD (cat "${pkgs.stdenv.cc}/nix-support/dynamic-linker")
      '';
    };
}
