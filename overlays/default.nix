{config, ...}: {
  flake.nixosModules.overlay = _: {
    nixpkgs.overlays = with config.flake.overlays; [openrgb];
    nixpkgs.config.allowUnfree = true;
  };

  flake.overlays = {
    openrgb = import ./openrgb;
    openthread-border-router = (final: prev: {
      openthread-border-router = config.flake.packages.openthread-border-router;
    });
  };
}
