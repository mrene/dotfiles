{ inputs, ... }:

{
  perSystem = { system, pkgs, ... }: {
    _module.args.pkgs = import inputs.nixpkgs { 
      inherit system; 
      config = {
       permittedInsecurePackages = [
         "electron-24.8.6"
       ];
        allowUnfree = true; 
      };
    };

    packages = (import ./default.nix) (pkgs // { inherit inputs; });
  };
}
