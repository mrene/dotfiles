# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, common, inputs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./home-assistant.nix
      ../../common/packages.nix
      ../../common/common.nix
    ];

  environment.systemPackages = [
    inputs.minidsp.packages.aarch64-linux.default
  ];

  # Prevent a lot of superfluous FS from being compiled
  boot.supportedFilesystems = lib.mkForce [ "ext4" "vfat" ];
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
  hardware.enableRedistributableFirmware = true;

  # Override this so ttyAMA0 isn't used for a console, since its shared with the 
  # bluetooth controller.
  boot.kernelParams = lib.mkForce [ "console=tty0" ];

  # Enables the generation of /boot/extlinux/extlinux.conf
  # which is laoded by u-boot
  boot.loader.generic-extlinux-compatible.enable = true;

  # !!! If your board is a Raspberry Pi 1, select this:
  #boot.kernelPackages = pkgs.linuxPackages_rpi;

  # Use the systemd-boot EFI boot loader.
  boot.loader.timeout = 5;

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  networking = {
    hostName = "tvpi";
    usePredictableInterfaceNames = false;

    interfaces.eth0.ipv4.addresses = [{
      address = "192.168.1.245";
      prefixLength = 24;
    }];

    defaultGateway = "192.168.1.1";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
  };

  users.users.root.openssh.authorizedKeys.keys = common.sshKeys;
  users.defaultUserShell = pkgs.fish;

  users.users.mrene = {
    isNormalUser = true;
    home = "/home/mrene";
    extraGroups = [
      "wheel"
    ];
    openssh.authorizedKeys.keys = common.sshKeys;
  };

  sdImage = {
    firmwareSize = 100;
    compressImage = false;
  };


  hardware.bluetooth.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    socketActivation = false;
  };
  services.pipewire.systemWide = true;

  networking.firewall.enable = false;
  services.tailscale = {
    enable = true;
  };

  services.minidsp = {
    enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}

