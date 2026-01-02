_: {
  flake.modules.nixos.tvpi =
    {
      lib,
      modulesPath,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      swapDevices = [ ];
      networking.useDHCP = lib.mkDefault true;
      powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
      nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
    };
}
