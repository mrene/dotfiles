{ inputs, ... }:
{
  perSystem =
    {
      lib,
      system,
      pkgs,
      ...
    }:
    rec {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          permittedInsecurePackages = [ ];
          allowUnfree = true;
        };
      };

      _module.args.sources = pkgs.callPackage ./_sources/generated.nix { };

      packages =
        let
          scope = lib.makeScope pkgs.newScope (self: {
            inherit inputs;
          });
        in
        lib.filesystem.packagesFromDirectoryRecursive {
          inherit (scope) callPackage;
          directory = ./packages;
        };
    };
}
