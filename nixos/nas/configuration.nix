{ config, pkgs, common, inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.nix-index-database.nixosModules.nix-index
    ./hardware-configuration.nix
    ./storage.nix
    ../common/common.nix
    ../common/packages.nix
    ../common/nvidia.nix
    ../common/distributed-build.nix
  ];

  boot = {
    loader = {
      grub = {
        enable = true;
        device = "nodev";
        useOSProber = false;
        efiSupport = true;
      };
      efi = {
        efiSysMountPoint = "/boot/efi";
        canTouchEfiVariables = true;
      };
    };
  };
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
    };

    mutableUsers = true;
    defaultUserShell = pkgs.fish;
  };

  # Prevent the X server from starting up
  services.xserver.displayManager.lightdm.enable = false;
  #systemd.units."display-manager.service".enable = false;

  security.sudo.wheelNeedsPassword = false;

  # Required for distributed builds
  users.users.root.openssh.authorizedKeys.keys = common.builderKeys;

  home-manager = {
    users.mrene = import ../../home-manager/nas.nix;

    useGlobalPkgs = true;
    verbose = true;
    extraSpecialArgs = { inherit inputs; };
  };

  services.tailscale.enable = true;

  nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3 --nogcroots";
  };

  # Required for nix-index 
  programs.command-not-found.enable = false;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" "armv6l-linux" ];
  nix.settings.substituters = [ "https://cache.armv7l.xyz" ];
  nix.settings.trusted-public-keys = [ "cache.armv7l.xyz-1:kBY/eGnBAYiqYfg0fy0inWhshUo+pGFM3Pj7kIkmlBk=" ];

  services.nix-serve = {
    enable = true;
    openFirewall = true;
    secretKeyFile = "/var/secrets/nix-builder.pem";
  };

  system.stateVersion = "23.11";
  nixpkgs.hostPlatform = "x86_64-linux";
}
