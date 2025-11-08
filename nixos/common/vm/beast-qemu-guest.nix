# REFACTOR PLAN: This file will become:
#   - homelab.vm.qemu-guest.enable (QEMU guest configuration)
{modulesPath, ...}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  services.xserver.videoDrivers = ["qxl" "virtio"];
  services.spice-vdagentd.enable = true;
  services.qemuGuest.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  fileSystems."/host-home" = {
    device = "home";
    fsType = "9p";
    options = ["trans=virtio" "version=9p2000.L" "rw" "loose" "msize=104857600"];
  };
}
