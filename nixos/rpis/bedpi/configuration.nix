# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  lib,
  pkgs,
  common,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../common/common.nix
    ../rpi1-quirks.nix
    ./bed-remote.nix
  ];

  # NixOS wants to enable GRUB by default
  #boot.loader.grub.enable = false;

  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # !!! If your board is a Raspberry Pi 1, select this:
  #boot.kernelPackages = pkgs.linuxPackages_rpi1;
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages;

  # Use the systemd-boot EFI boot loader.

  boot.kernelParams = ["console=ttyAMA0" "earlyprintk" "mitigations=off"];
  boot.loader.timeout = 5;
  boot.supportedFilesystems = lib.mkForce ["ext4" "vfat"];

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

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  networking = {
    hostName = "bedpi";
    usePredictableInterfaceNames = false;

    interfaces.eth0.ipv4.addresses = [
      {
        address = "192.168.1.244";
        prefixLength = 24;
      }
    ];

    defaultGateway = "192.168.1.1";
    nameservers = ["1.1.1.1" "8.8.8.8"];
  };

  environment.systemPackages = with pkgs; [
  ];

  sdImage = {
    firmwareSize = 100;
    compressImage = false;
  };

  #nix.binaryCaches = [ "https://cache.armv7l.xyz" ];
  #nix.binaryCachePublicKeys = [ "cache.armv7l.xyz-1:kBY/eGnBAYiqYfg0fy0inWhshUo+pGFM3Pj7kIkmlBk=" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
