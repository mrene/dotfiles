_: {
  flake.modules.nixos.beast =
    { config, ... }:
    {
      # Use zenpower to report thermals, instead of the builtin k10temp
      boot.kernelModules = [ "zenpower" ];
      boot.extraModulePackages = with config.boot.kernelPackages; [ zenpower ];
      boot.blacklistedKernelModules = [
        "k10temp"
        "acpi-cpufreq"
      ];
      boot.kernelParams = [ "amd_pstate=active" ];
    };
}
