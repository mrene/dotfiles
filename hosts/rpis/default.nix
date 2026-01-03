{
  inputs,
  config,
  ...
}:
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

  clan.machines.tvpi.imports = [
    # Required: Add necessary overlays with kernel, firmware, vendor packages
    inputs.nixos-raspberrypi.lib.inject-overlays
    # Binary cache with prebuilt packages
    inputs.nixos-raspberrypi.nixosModules.trusted-nix-caches
    # RPi5 hardware modules
    inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
    inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.bluetooth
    # SD card image builder
    "${inputs.nixos-raspberrypi}/modules/installer/sd-card/sd-image-raspberrypi.nix"
    # Standard modules
    config.flake.modules.nixos.all
    config.flake.modules.nixos.tvpi
    config.flake.nixosModules.overlay
    # Rpi-specific config
    { nixpkgs.config.allowUnfree = true; }
  ];
}
