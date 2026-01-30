{
  lib,
  inputs,
  config,
  ...
}:
{
  flake-file.inputs = {
    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Direct reference to CI-built nixos-raspberrypi to avoid rebuilding the kernel
    nixos-raspberrypi-nofollows.url = "github:nvmd/nixos-raspberrypi/main";
  };

  clan.machines.tvpi = {
    clan.core.networking = {
      buildHost = "mrene@utm";
      targetHost = "root@tvpi.tailc705a.ts.net";
    };

    imports =
      (lib.attrValues {
        inherit (inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5)
          base
          bluetooth
          ;

        inherit (config.flake.modules.nixos)
          core-base
          core-ssh-ca
          system-common-packages
          services-sops
          services-restic
          services-dyndns
          services-prs
          ;
      })
      ++ [
        inputs.nixos-raspberrypi.lib.inject-overlays
        inputs.nixos-raspberrypi.nixosModules.trusted-nix-caches
        config.flake.modules.nixos.tvpi
        "${inputs.nixos-raspberrypi}/modules/installer/sd-card/sd-image-raspberrypi.nix"
        { nixpkgs.config.allowUnfree = true; }
      ];
  };
}
