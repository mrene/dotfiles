{inputs, ...}: {
  perSystem = {
    lib,
    system,
    pkgs,
    ...
  }: rec {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config = {
        permittedInsecurePackages = [
          "electron-24.8.6"
          "electron-25.9.0"
        ];
        allowUnfree = true;
      };
    };

    _module.args.sources = pkgs.callPackage ./_sources/generated.nix {};

    packages = let
      scope = lib.makeScope pkgs.newScope (self: {inherit inputs;});
    in
      lib.filesystem.packagesFromDirectoryRecursive {
        inherit (scope) callPackage;
        directory = ./packages;
      };
  };
}
