{ config, common, pkgs, inputs, ... }:

{
  # Graphics
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;

    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
}
