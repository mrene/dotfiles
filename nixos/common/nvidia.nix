{pkgs, ...}: {
  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
  services.xserver.enable = true;
  services.xserver.videoDrivers = ["nvidia"];
}
