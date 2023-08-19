{ config, ... }:

{
  flake.nixosModules.overlay = _: {
    nixpkgs.overlays = with config.flake.overlays; [ openrgb ];
    nixpkgs.config.allowUnfree = true;
  };

  flake.overlays = {
    openrgb = import ./openrgb;
  };
}
