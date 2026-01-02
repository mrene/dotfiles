{ lib, inputs, ... }:
{
  flake-file.inputs.vscode-server = {
    url = "github:msteen/nixos-vscode-server";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.aspects.dev-vscode-server.nixos =
    { config, pkgs, ... }:
    let
      cfg = config.homelab.vscode-server;
    in
    {
      imports = lib.optionals (inputs ? vscode-server) [
        inputs.vscode-server.nixosModule
      ];

      options.homelab.vscode-server = {
        enable = lib.mkEnableOption "Enable VS Code remote server support";
      };

      config = lib.mkIf cfg.enable {
        services.vscode-server.enable = lib.mkDefault true;
      };
    };
}
