# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, common, pkgs, ... }:

{
  imports = [
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

  networking.networkmanager.enable = true;
  networking.hostName = "beast";
  #networking.wireless.enable = true;

  # Graphics
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;

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

    #Audio
    roomeqwizard
    spotify
    audacity

    # HW support
    #razergenie #mouse
    openrazer-daemon

    nvtop-nvidia # htop-like gpu load viewer
  ];

  services.vscode-server.enable = true;
  services.openssh.enable = true;

  services.tailscale.enable = true;
  networking.firewall.checkReversePath = "loose";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
