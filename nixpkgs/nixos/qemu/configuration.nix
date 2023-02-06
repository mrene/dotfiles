# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, common, pkgs, inputs, ... }:

{
  imports =
    [
      inputs.home-manager.nixosModules.home-manager
      inputs.vscode-server.nixosModule

      # Include the results of the hardware scan.
       ./hardware-configuration.nix
      ../common/minikube.nix
      ../common/vm/beast-qemu-guest.nix
      ../common/gui/base.nix

      ../common/gui/dev-kitchen-sink.nix
    ];

  home-manager = {
    users.mrene = import ../../home-manager/utm.nix;

    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;
    extraSpecialArgs = { inherit inputs; };
  };

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  # Enable networking
  networking = {
    hostName = "nixos-qemu";
    networkmanager.enable = true;
  };


  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "qxl" "virtio" ];
  services.spice-vdagentd.enable = true;
  services.qemuGuest.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;
  # services.xserver.windowManager.awesome.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  virtualisation.docker = {
    enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    google-chrome

    # Dev tooling
    vscode-with-extensions


    # Messaging
    slack
    discord

    # Notes 
    logseq

    _1password-gui
    flameshot # Screenshot software

    keybase
    keybase-gui

    simplescreenrecorder

    #Audio
    roomeqwizard
    spotify
    audacity

    # HW support
    #razergenie #mouse
    openrazer-daemon
    openrgb


    screenfetch
    alacritty
  ];

  services.vscode-server.enable = true;
  services.openssh.enable = true;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
