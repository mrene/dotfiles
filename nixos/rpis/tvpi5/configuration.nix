# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  lib,
  config,
  pkgs,
  common,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # ../tvpi/home-assistant
    # ../../modules
  ];

  # Enable refactored homelab modules
  # homelab.vm-common.enable = true;
  # homelab.ssh-ca.enable = true;
  # homelab.common-packages.enable = true;

  # Prevent a lot of superfluous FS from being compiled
  # boot.supportedFilesystems = lib.mkForce ["ext4" "vfat"];
  hardware.enableRedistributableFirmware = true;

  # Override this so ttyAMA0 isn't used for a console, since its shared with the
  # bluetooth controller.
  # boot.kernelParams = lib.mkForce ["console=tty0"];

  # Enables the generation of /boot/extlinux/extlinux.conf
  # which is laoded by u-boot
  # boot.loader.generic-extlinux-compatible.enable = true;

  # !!! If your board is a Raspberry Pi 1, select this:
  #boot.kernelPackages = pkgs.linuxPackages_rpi;

  # Use the systemd-boot EFI boot loader.
  # boot.loader.timeout = 5;

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  # homelab.sops.enable = true;
  # sops.secrets."home-assistant/token" = {
  #   owner = config.users.users.mrene.name;
  # };

  # homelab.backups.enable = true;
  # homelab.dyndns.enable = true;

  networking = {
    hostName = "tvpi5";
    usePredictableInterfaceNames = false;

    # interfaces.eth0.ipv4.addresses = [
    #   {
    #     address = "192.168.1.245";
    #     prefixLength = 24;
    #   }
    # ];

    defaultGateway = "192.168.1.1";
    nameservers = ["1.1.1.1" "8.8.8.8"];
  };

  hardware.raspberry-pi.config.all.base-dt-params = {
    pciex1 = {
      enable = true;
    };
  };
  boot.kernelParams = [
    "pcie_aspm=off"
    "pci=pcie_bus_perf"
    "pci=earlydump"
  ];

  # Required for distributed builds
  users.users.root.openssh.authorizedKeys.keys = common.builderKeys ++ common.sudoSshKeys ++ common.sshKeys;
  users.defaultUserShell = pkgs.fish;
  programs.fish.enable = true;

  users.users.mrene = {
    isNormalUser = true;
    home = "/home/mrene";
    extraGroups = [
      "wheel"
    ];
    openssh.authorizedKeys.keys = common.sshKeys;
  };

  # sdImage = {
  #   firmwareSize = 100;
  #   compressImage = false;
  # };

  # hardware.bluetooth.enable = true;

  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  #   pulse.enable = true;
  #   socketActivation = false;
  # };
  # services.pipewire.systemWide = true;

  networking.firewall.enable = false;
  services.tailscale = {
    enable = true;
    extraUpFlags = [ "--advertise-exit-node" ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
