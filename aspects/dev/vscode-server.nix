{ lib, inputs, ... }:
{
  flake-file.inputs.vscode-server = {
    url = "github:msteen/nixos-vscode-server";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.aspects.dev-vscode-server.nixos = _: {
    imports = lib.optionals (inputs ? vscode-server) [
      inputs.vscode-server.nixosModule
    ];

    services.vscode-server.enable = lib.mkDefault true;
  };
}
