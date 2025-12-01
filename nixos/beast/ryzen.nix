# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
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
}
