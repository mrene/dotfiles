{ lib, config, pkgs, flakePackages, ... }:

let
  cfg = config.homelab.gui.dev;
in
{
  options.homelab.gui.dev = {
    enable = lib.mkEnableOption "Enable homelab development tools (VSCode, Windsurf, etc)";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      flakePackages.${system}.vscode-with-extensions
      flakePackages.${system}.windsurf-with-extensions

      # These need to be in the global PATH for goland to work correctly
      gcc
      mypy
      glibc.dev
    ];
  };
}
