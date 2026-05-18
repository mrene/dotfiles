{ lib, inputs, ... }:
{
  flake-file.inputs.vscode-server = {
    url = "github:msteen/nixos-vscode-server";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.dev-gui = {
    imports = lib.optionals (inputs ? vscode-server) [
      inputs.vscode-server.nixosModule
    ];

    services.vscode-server.enable = lib.mkDefault true;
  };
}
