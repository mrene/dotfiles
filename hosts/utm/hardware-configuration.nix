_: {
  flake.modules.nixos.utm =
    {
      lib,
      modulesPath,
      ...
    }:
    {
      imports = [
        (modulesPath + "/profiles/qemu-guest.nix")
      ];

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "virtio_pci"
        "usbhid"
        "usb_storage"
        "sr_mod"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/d64994c4-9465-42b1-ac41-f82f9be5fff1";
        fsType = "ext4";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/D5B2-FF8F";
        fsType = "vfat";
      };

      swapDevices = [ ];

      networking.useDHCP = lib.mkDefault true;
      nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
    };
}
