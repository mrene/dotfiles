# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, common, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
       ./hardware-configuration.nix
      ../minikube.nix
    ];

  nix = {
    package = pkgs.nixUnstable; # or versioned attributes like nix_2_4
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
   };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "utm-nixos";
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.enable = true;

  security.sudo.wheelNeedsPassword = false;

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  users = {
    users.mrene = {
      isNormalUser = true;
      extraGroups = [ 
        "wheel"   # Allow sudo
        "docker"  # Allow docker access
      ];
      openssh.authorizedKeys.keys = common.sshKeys;
      initialHashedPassword = "";
    };

    defaultUserShell = pkgs.fish;
  };

  virtualisation.docker = {
    enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
    wget
    curl
    direnv
    nix-direnv

    # Dev tooling
    vscode-with-extensions

    # Messaging
    slack
    discord
  ];

  programs.mtr.enable = true;
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.vscode-server.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}

