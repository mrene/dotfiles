{ config, pkgs, common, inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.nix-index-database.nixosModules.nix-index
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
  networking.hostName = "nas";
  networking.firewall.enable = false;
  services.openssh.enable = true;
  users = {
    users = {
      mrene = {
        isNormalUser = true;
        description = "mathieu";
        extraGroups = [
          "wheel"
          "docker"
          "networkmanager"
        ];
        openssh.authorizedKeys.keys = common.sshKeys;
      };
      root.openssh.authorizedKeys.keys = common.sshKeys;
    };

    mutableUsers = true;
    defaultUserShell = pkgs.fish;
  };
  security.sudo.wheelNeedsPassword = false;

  home-manager = {
    users.mrene = import ../../home-manager/nas.nix;

    useGlobalPkgs = true;
    #useUserPackages = true;
    verbose = true;
    extraSpecialArgs = { inherit inputs; };
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
  ];

  # Required for nix-index 
  programs.command-not-found.enable = false;

  system.stateVersion = "23.11";
  nixpkgs.hostPlatform = "x86_64-linux";
}
