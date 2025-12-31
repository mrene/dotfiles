{
  inputs,
  self,
  config,
  ...
}:
let
  # https://github.com/nvmd/nixos-raspberrypi/issues/113
  inherit (inputs) nixpkgs;
  inherit (nixpkgs) lib;

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
  flake.nixosConfigurations = {
    tvpi = inputs.nixos-raspberrypi.lib.nixosSystem {
      system = "aarch64-linux";
      lib = patchedLib;
      specialArgs = {
        inherit (self) common;
        inherit inputs;
        inherit (inputs) nixos-raspberrypi;
      };
      modules = [
        "${inputs.nixos-raspberrypi}/modules/installer/sd-card/sd-image-raspberrypi.nix"
        ./tvpi5/configuration.nix
        config.flake.nixosModules.all
        (_: {
          imports = with inputs.nixos-raspberrypi.nixosModules; [
            raspberry-pi-5.base
            raspberry-pi-5.bluetooth
          ];
          nixpkgs.config.allowUnfree = true;
        })
      ];
    };
  };
}
