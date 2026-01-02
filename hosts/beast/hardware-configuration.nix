_: {
  flake.modules.nixos.beast =
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
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-amd" ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/4d43879e-dad2-4159-a6af-844c23d04378";
        fsType = "ext4";
        neededForBoot = true;
      };

      fileSystems."/bulk" = {
        device = "/dev/disk/by-uuid/9e43d788-e180-41d9-b46e-55e782bb2593";
        fsType = "ext4";
        neededForBoot = false;
      };

      fileSystems."/var/lib/docker" = {
        device = "/bulk/docker";
        options = [ "bind" ];
      };

      fileSystems."/boot/efi" = {
        device = "/dev/disk/by-uuid/D6FD-510A";
        fsType = "vfat";
      };

      swapDevices = [ ];

      networking.useDHCP = lib.mkDefault true;
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
