{ lib, ... }:
let
  folder = ./_cachix;
  toImport = name: _value: folder + ("/" + name);
  filterCaches = key: value: value == "regular" && lib.hasSuffix ".nix" key;
  cachixImports = lib.mapAttrsToList toImport (
    lib.filterAttrs filterCaches (builtins.readDir folder)
  );
in
{
  flake.aspects.infra-cachix.nixos = _: {
    # Dynamically import all .nix files from ./_cachix/
    imports = cachixImports;

    nix.settings.substituters = [ "https://cache.nixos.org/" ];
  };
}
