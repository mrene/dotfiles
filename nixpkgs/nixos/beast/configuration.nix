# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, common, pkgs, ... }:

{
  imports = [
    ../minikube.nix
    ./desktop.nix
  ];

  nix.settings.experimental-features = [ "flakes" "nix-command" ];

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

  networking.hostName = "beast"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Graphics
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

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
        extraGroups = [ "networkmanager" "wheel" "docker"];
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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    usbutils
    pciutils
    lm_sensors
    
    neovim
    wget
    curl
    direnv
    nix-direnv
    git

    google-chrome
    firefox

    # Dev tooling
    vscode-with-extensions
    jetbrains.goland
    jetbrains.pycharm-professional
    jetbrains.datagrip
    jetbrains.clion

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

    screenfetch
    alacritty
    wezterm
  ];

  programs.mtr.enable = true;
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

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
