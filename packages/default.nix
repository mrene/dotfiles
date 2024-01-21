{
  lib,
  callPackage,
  inputs,
  ...
}:
# Import all directories as their own package
let
  packageDirectories = lib.filterAttrs (_k: v: v == "directory") (builtins.readDir ./.);
in
  builtins.mapAttrs (k: _v: (callPackage (./. + ("/" + k)) {inherit inputs;})) packageDirectories
