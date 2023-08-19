{ inputs, ... }:

{
  perSystem = { system, pkgs, ... }: {
    packages = ((import ./default.nix) (pkgs // { inherit inputs; }));
  };
}
