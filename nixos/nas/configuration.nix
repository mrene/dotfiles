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
    ../common/radio.nix
    ../common/cachix.nix
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
      # Backup thread netdata (includes network credentials (aka "dataset"))
      "/var/lib/thread"
    ];
  };
  homelab.attic.enable = true;
  homelab.caddy.enable = true;
  homelab.dyndns.enable = true;

  services.openthread-border-router = {
    enable = true;
    backboneInterface = "enp2s0";
    logLevel = "err";
    radio =  {
      device = "/dev/serial/by-id/usb-Nabu_Casa_SkyConnect_v1.0_a8cf5592bed8ed1198a76f6162c613ac-if00-port0";
      baudRate = 460800;
      extraDevices = [ "trel://enp2s0" ];
    };
    rest = {
      listenPort = 58081;
    };
    web = {
      enable = true;
      listenPort = 58082;
    };
  };

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

  services.sabnzbd = {
    enable = true;
    user = "jellyfin";
    group = "jellyfin";
  };

  services.jellyfin = {
    enable = true;
  };

  services.ncps = {
    enable = true;
    cache = {
      hostName = "nas";
      allowPutVerb = true;
      maxSize = "100G";
    };
    upstream = {
      caches = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
      ];
      publicKeys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  system.stateVersion = "23.11";
  nixpkgs.hostPlatform = "x86_64-linux";
}
