{ config, pkgs, common, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../common/common.nix
    ../common/packages.nix
  ];

  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      useOSProber = true;
      efiSupport = true;
    };
    efi = {
      efiSysMountPoint = "/boot/efi";
      canTouchEfiVariables = true;
    };
  };

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;

  networking.hostId = "f7717cca";
  networking.hostName = "nas"; # empty
  networking.firewall.enable = false;
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = common.sshKeys;


  environment.systemPackages = with pkgs; [
    git
    vim
    wget
  ];

  system.stateVersion = "23.11";
  nixpkgs.hostPlatform = "x86_64-linux";
}
