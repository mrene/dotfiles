{ config, ... }:

{
  flake.nixosModules.overlay = { ... }: {
    nixpkgs.overlays = with config.flake.overlays; [ openrgb ];
    nixpkgs.config.allowUnfree = true;
  };

  flake.overlays = {
    openrgb = (import ./openrgb);
  };
}
