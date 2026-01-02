{ inputs, ... }:
{
  # Declare inputs used by this module for flake-file tracking
  flake-file.inputs.nix-vscode-extensions = {
    url = "github:nix-community/nix-vscode-extensions";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  perSystem =
    {
      lib,
      system,
      pkgs,
      ...
    }:
    {
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
