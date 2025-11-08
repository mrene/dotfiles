{ lib, config, modulesPath, ... }:

let
  cfg = config.homelab.vm.qemu-guest;
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  options.homelab.vm.qemu-guest = {
    enable = lib.mkEnableOption "Enable homelab QEMU guest configuration";
  };

  config = lib.mkIf cfg.enable {
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
  };
}
