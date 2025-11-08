{ lib, config, pkgs, ... }:

let
  cfg = config.homelab.nvidia;
in
{
  options.homelab.nvidia = {
    enable = lib.mkEnableOption "Enable homelab NVIDIA configuration (drivers, CUDA)";
  };

  config = lib.mkIf cfg.enable {
    # Graphics
    hardware.graphics = {
      enable = true;
      enable32Bit = true;

      extraPackages = with pkgs; [
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };
    hardware.nvidia.open = false;

    hardware.nvidia.package = config.boot.kernelPackages.nvidia_x11_production;
    services.xserver.enable = true;
    services.xserver.videoDrivers = ["nvidia"];
    nixpkgs.config.cudaSupport = true;
  };
}
