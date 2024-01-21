{ callPackage }:

let
  sources = callPackage ./generated.nix {};
in
  {
    inherit sources;
    dockerImageUrl = name: sources.${name}.src.sourceURL;
    fetch = name: sources.${name}.src;
  }
