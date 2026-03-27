{ inputs, ... }:

let
  overlay = _: {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.permittedInsecurePackages = [ "electron-38.8.4" ];
  };

  hmUnstable =
    { pkgs, lib, ... }:
    let
      unstablePkgs = import inputs.nixpkgs-unstable {
        inherit (pkgs) system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [ "electron-38.8.4" ];
        };
      };
    in
    {
      home-manager.useGlobalPkgs = false;
      home-manager.extraSpecialArgs.stablePkgs = pkgs;
      home-manager.sharedModules = [
        { _module.args.pkgs = lib.mkForce unstablePkgs; }
      ];
    };
in
{
  flake.nixosModules.overlay = overlay;
  flake.darwinModules.overlay = overlay;
  flake.nixosModules.hmUnstable = hmUnstable;
  flake.darwinModules.hmUnstable = hmUnstable;
}
