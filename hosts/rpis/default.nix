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
  # Declare inputs used by this host for flake-file tracking
  flake-file.inputs = {
    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Direct reference to CI-built nixos-raspberrypi to avoid rebuilding the kernel
    nixos-raspberrypi-nofollows.url = "github:nvmd/nixos-raspberrypi/main";
  };

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
        config.flake.modules.nixos.tvpi
        inputs.sops-nix.nixosModules.sops
        config.flake.modules.nixos.all
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
