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

      gcc
      mypy
      glibc.dev
    ] ++ lib.optionals (pkgs.system != "aarch64-linux") [
      flakePackages.${pkgs.system}.windsurf-with-extensions
    ];
  };
}
