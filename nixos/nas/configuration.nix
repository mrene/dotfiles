{
  pkgs,
  common,
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    ./storage.nix
    ../common/common.nix
    ../common/packages.nix
    ../common/nvidia.nix
    ../common/distributed-build.nix
    ../modules
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

  homelab.sops.enable = true;
  homelab.backups = {
    enable = true;
    paths = [
      "/bulk/replicated"
    ];
  };
  homelab.attic.enable = true;


  # Prevent the X server from starting up
  services.xserver.displayManager.lightdm.enable = false;
  #systemd.units."display-manager.service".enable = false;

  security.sudo.wheelNeedsPassword = false;

  # Required for distributed builds
  users.users.root.openssh.authorizedKeys.keys = common.builderKeys ++ common.sudoSshKeys;

  home-manager = {
    users.mrene = import ../../home-manager/nas.nix;

    useGlobalPkgs = true;
    verbose = true;
    extraSpecialArgs = {inherit inputs;};
  };

  services.tailscale.enable = true;

  programs.nh = {
    enable = true;
    clean.enable = false;
  };

  # Required for nix-index
  programs.command-not-found.enable = false;

  boot.binfmt.emulatedSystems = ["aarch64-linux" "armv6l-linux"];

  services.nix-serve = {
    enable = true;
    openFirewall = true;
    secretKeyFile = "/var/secrets/nix-builder.pem";
  };

  system.stateVersion = "23.11";
  nixpkgs.hostPlatform = "x86_64-linux";
}
