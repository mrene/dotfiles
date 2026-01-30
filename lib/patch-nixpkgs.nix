# https://github.com/nvmd/nixos-raspberrypi/issues/113
# Patch lib.mkRemovedOptionModule to add a `key` attribute for module deduplication
{ lib }:
let
  patchedLib = lib.extend (
    final: prev: {
      mkRemovedOptionModule =
        optionName: replacementInstructions:
        let
          key = "removedOptionModule#" + final.concatStringsSep "_" optionName;
        in
        { options, ... }:
        (lib.mkRemovedOptionModule optionName replacementInstructions { inherit options; })
        // {
          inherit key;
        };
    }
  );
in
{
  inherit patchedLib;

  # Helper to patch inputs with the patched lib
  patchInputs = inputs: inputs // {
    nixpkgs = inputs.nixpkgs // {
      inherit patchedLib;
      lib = patchedLib;
    };
  };
}
