{ inputs, self, config, ... }:

let
  overlays = with config.flake.overlays; [ packages openrgb vscode ];
  rpiOverlays = [
    (final: super: {
      # Allow missing modules because the master module list is based on strings and the rpi kernel
      # is missing some
      # https://github.com/NixOS/nixpkgs/issues/154163
      makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];

  rpi1pkgs = import inputs.nixpkgs-frozen {
    config = { allowUnfree = true; };
    overlays = overlays ++ rpiOverlays;
    system = "x86_64-linux";
    crossSystem = {
      system = "armv6l-linux";
      # https://discourse.nixos.org/t/building-libcamera-for-raspberry-pi/26133/9
      gcc = {
        arch = "armv6k";
        fpu = "vfp";
      };
    };
  };
in
{
  flake.nixosConfigurations = {
    # rpi1 + bladeRF
    bedpi = inputs.nixpkgs-frozen.lib.nixosSystem {
      pkgs = rpi1pkgs;
      specialArgs = { inherit (self) common; inherit inputs; };
      modules = [
        ./bedpi/configuration.nix
        "${inputs.nixpkgs-frozen}/nixos/modules/installer/sd-card/sd-image-raspberrypi.nix"
      ];
    };

    # test rpi1
    testpi = inputs.nixpkgs-frozen.lib.nixosSystem {
      pkgs = rpi1pkgs;
      specialArgs = { inherit (self) common; inherit inputs; };
      modules = [
        ./testpi/configuration.nix
        "${inputs.nixpkgs-frozen}/nixos/modules/installer/sd-card/sd-image-raspberrypi.nix"
      ];
    };

    # rpi4
    tvpi = inputs.nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { common = self.common; inherit inputs; };
      modules = [
        inputs.nixos-hardware.outputs.nixosModules.raspberry-pi-4
        "${inputs.nixpkgs-frozen}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        ./tvpi/configuration.nix
        ({ ... }: {
          nixpkgs.config.allowUnfree = true;
          nixpkgs.overlays = overlays ++ rpiOverlays;
        })
      ];
    };
  };
}
