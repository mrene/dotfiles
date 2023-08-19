{ lib, callPackage, inputs, ... }:

# Import all directories as their own package
let
  packageDirectories = lib.filterAttrs (k: v: v == "directory") (builtins.readDir ./.);
in
builtins.mapAttrs (k: v: (callPackage (./. + ("/" + k)) { inherit inputs; })) packageDirectories

