{ config, ... }:

let
  overlay = _: {
    # nixpkgs.overlays = with config.flake.overlays; [openrgb];
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.permittedInsecurePackages = [ "electron-38.8.4" ];
  };
in
{
  flake.nixosModules.overlay = overlay;
  flake.darwinModules.overlay = overlay;
}
