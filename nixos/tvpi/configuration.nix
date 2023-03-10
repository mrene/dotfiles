# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, common, inputs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # NixOS wants to enable GRUB by default
  #boot.loader.grub.enable = false;
  #boot.loader.raspberryPi = {
  #enable = true;
  #version = 4;
  #};

  boot = {
    #kernelPackages = pkgs.linuxPackages_rpi4;
    #initrd.availableKernelModules = [ "usbhid" "usb_storage" ];
    # ttyAMA0 is the serial console broken out to the GPIO
    #kernelParams = [
    #"8250.nr_uarts=1"
    #"console=ttyAMA0,115200"
    #"console=tty1"
    ## A lot GUI programs need this, nearly all wayland applications
    #"cma=128M"
    #];
  };

  boot.supportedFilesystems = lib.mkForce [ "ext4" "vfat" ];
  hardware.enableRedistributableFirmware = true;

  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # !!! If your board is a Raspberry Pi 1, select this:
  #boot.kernelPackages = pkgs.linuxPackages_rpi;

  # Use the systemd-boot EFI boot loader.
  boot.loader.timeout = 5;

  services.openssh.enable = true;

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
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}

