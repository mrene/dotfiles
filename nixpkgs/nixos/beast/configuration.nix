# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, common, pkgs, inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.hyprland.nixosModules.default
    inputs.vscode-server.nixosModule

    ./hardware-configuration.nix
    ./ryzen.nix
    ../common/cachix.nix
    ../common/minikube.nix
    ../common/common.nix
    ../common/gui/dev-kitchen-sink.nix
    ../common/gui/desktop.nix
    ../common/gui/base.nix
    ../common/gui/messaging.nix
  ];

  # Bootloader.
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

  boot.kernelPackages = pkgs.linuxPackages_6_1;
  # Sensors
  boot.kernelModules = [ "nct6775" ];

  networking.networkmanager.enable = true;
  networking.hostName = "beast";
  #networking.wireless.enable = true;

  # Graphics
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;

    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  #hardware.nvidia.modesetting.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };

  hardware.openrazer = {
    enable = true;
    mouseBatteryNotifier = true;
    users = [ "mrene" ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    users = {
      mrene = {
        isNormalUser = true;
        description = "mathieu";
        extraGroups = [ "networkmanager" "wheel" "docker" ];
        openssh.authorizedKeys.keys = common.sshKeys;
        initialHashedPassword = "";
      };
      root = {
        openssh.authorizedKeys.keys = common.sudoSshKeys;
      };
    };

    defaultUserShell = pkgs.fish;
  };

  home-manager = {
    users.mrene = import ../../home-manager/beast.nix;

    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;
    extraSpecialArgs = { inherit inputs; };
  };

  security.sudo.wheelNeedsPassword = true;
  security.pam.enableSSHAgentAuth = true;

  virtualisation.docker = {
    enable = true;
    enableNvidia = true;
  };

  environment.systemPackages = with pkgs; [
    minidsp

    # Notes 
    logseq
    zotero

    #Audio
    roomeqwizard
    spotify
    audacity

    # HW support
    #razergenie #mouse
    openrazer-daemon

    nvtop-nvidia # htop-like gpu load viewer
    nvitop
    rgb-auto-toggle
  ];

  services.vscode-server.enable = true;
  services.openssh.enable = true;

  services.tailscale.enable = true;
  networking.firewall.checkReversePath = "loose";

  # TODO: Onprem package req, remove after.
  services.k3s.enable = true;
  virtualisation.libvirtd.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
