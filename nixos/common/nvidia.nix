{pkgs, config, ...}: {
  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
  hardware.nvidia.open = true;

  hardware.nvidia.package = config.boot.kernelPackages.nvidia_x11_production;
  services.xserver.enable = true;
  services.xserver.videoDrivers = ["nvidia"];
}
