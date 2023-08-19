{ inputs, ... }:

{
  perSystem = { system, pkgs, ... }: {
    _module.args.pkgs = import inputs.nixpkgs { 
      inherit system; 
      config = { allowUnfree = true; };
    };

    packages = (import ./default.nix) (pkgs // { inherit inputs; });
  };
}
