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
  flake.aspects.infra-cachix.nixos =
    { config, ... }:
    let
      cfg = config.homelab.cachix;
    in
    {
      # Dynamically import all .nix files from ./_cachix/
      imports = cachixImports;

      options.homelab.cachix = {
        enable = lib.mkEnableOption "Enable homelab cachix binary caches";
      };

      config = lib.mkIf cfg.enable {
        nix.settings.substituters = [ "https://cache.nixos.org/" ];
      };
    };
}
