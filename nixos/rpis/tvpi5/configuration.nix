# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  lib,
  config,
  pkgs,
  common,
  inputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../tvpi/home-assistant
    ../../modules
  ];

  # Enable refactored homelab modules
  homelab.vm-common.enable = true;
  homelab.ssh-ca.enable = true;
  homelab.common-packages.enable = true;

  # Override the kernel package to use the upstream nixos-raspberrypi prebuilt kernel (without
  # overriding nixpkgs)
  boot.kernelPackages = inputs.nixos-raspberrypi-nofollows.packages.${pkgs.stdenv.hostPlatform.system}.linuxPackages_rpi5;
  hardware.enableRedistributableFirmware = true;
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  homelab.sops.enable = true;
  sops.secrets."home-assistant/token" = {
    owner = config.users.users.mrene.name;
  };

  homelab.backups.enable = true;
  homelab.dyndns.enable = true;

  networking = {
    hostName = "tvpi";
    usePredictableInterfaceNames = false;

    interfaces.eth0.ipv4.addresses = [
      {
        address = "192.168.1.245";
        prefixLength = 24;
      }
    ];

    defaultGateway = "192.168.1.1";
    nameservers = ["1.1.1.1" "8.8.8.8"];
  };

  # Enable nvme ssd
  hardware.raspberry-pi.config.all.base-dt-params = {
    pciex1 = {
      enable = true;
    };
  };

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

  hardware.bluetooth.enable = true;

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
