{ config, ... }:

let
  packageOverlay = (final: prev: ((import ../packages) prev));
in
{
  flake.nixosModules.overlay = { ... }: {
    nixpkgs.overlays = with config.flake.overlays; [ packages vscode openrgb ];
    nixpkgs.config.allowUnfree = true;
  };

  flake.overlays = {
    packages = packageOverlay;
    vscode = (import ./vscode-with-extensions.nix);
    openrgb = (import ./openrgb);
  };
}
