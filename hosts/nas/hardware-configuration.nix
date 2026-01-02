_: {
  flake.modules.nixos.nas =
    {
      config,
      lib,
      modulesPath,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.initrd.availableKernelModules = [
        "ahci"
        "xhci_pci"
        "nvme"
        "usbhid"
        "sd_mod"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/6c78c58a-3471-46b3-a783-2c34c269c1bf";
        fsType = "ext4";
      };

      fileSystems."/boot/efi" = {
        device = "/dev/disk/by-uuid/7143-C9E3";
        fsType = "vfat";
      };

      swapDevices = [ { device = "/dev/disk/by-uuid/10f48477-ab50-4762-93a1-d2018ca6ebf0"; } ];

      networking.useDHCP = lib.mkDefault true;
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
