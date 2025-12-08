{
  inputs,
  self,
  config,
  ...
}: let
  rpiOverlays = [
    (_final: super: {
      # Allow missing modules because the master module list is based on strings and the rpi kernel
      # is missing some
      # https://github.com/NixOS/nixpkgs/issues/154163
      makeModulesClosure = x: super.makeModulesClosure (x // {allowMissing = true;});
    })
  ];
in {
  flake.nixosConfigurations = {
    # rpi4
    tvpi = inputs.nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = {
        inherit (self) common;
        inherit inputs;
      };
      modules = [
        inputs.nixos-hardware.nixosModules.raspberry-pi-4
        "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        ./tvpi/configuration.nix
        (_: {
          nixpkgs.config.allowUnfree = true;
          nixpkgs.overlays = rpiOverlays;
        })
      ];
    };

    tvpi5 = inputs.nixos-raspberrypi.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = {
        inherit (self) common;
        inherit inputs;
        inherit (inputs) nixos-raspberrypi;
      };
      modules = [
        "${inputs.nixos-raspberrypi}/modules/installer/sd-card/sd-image-raspberrypi.nix"
        ./tvpi5/configuration.nix
        (_: {
          imports = with inputs.nixos-raspberrypi.nixosModules; [
            raspberry-pi-5.base
            raspberry-pi-5.bluetooth
          ];
          nixpkgs.config.allowUnfree = true;
          nixpkgs.overlays = rpiOverlays;
        })
      ];
    };
  };
}
