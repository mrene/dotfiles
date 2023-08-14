# edit this configuration file to define what should be installed on
# your system.  help is available in the configuration.nix(5) man page
# and in the nixos manual (accessible by running ‘nixos-help’).

{ config, common, pkgs, inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.vscode-server.nixosModule
    inputs.nix-index-database.nixosModules.nix-index
    inputs.nh.nixosModules.default
    inputs.minidsp.nixosModules.default


    ./hardware-configuration.nix
    ./ryzen.nix
    ./rgb.nix
    ./bt-speaker.nix

    ../common/nvidia.nix
    ../common/distributed-build.nix
    ../common/cachix.nix
    ../common/minikube.nix
    ../common/common.nix
    ../common/packages.nix
    ../common/gui/dev-kitchen-sink.nix
    ../common/gui/desktop.nix
    ../common/gui/base.nix
    ../common/gui/messaging.nix

    ../common/radio.nix
  ];

  nh = {
    enable = true;
    #package = inputs.nh.packages.${pkgs.system}.default;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3 --nogcroots";
  };

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

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Sensors
  boot.kernelModules = [ "nct6775" ];

  networking.networkmanager.enable = true;
  networking.hostName = "beast";

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
        openssh.authorizedKeys.keys = common.sudoSshKeys ++ common.builderKeys;
      };
    };

    defaultUserShell = pkgs.fish;
  };

  home-manager = {
    users.mrene = import ../../home-manager/beast.nix;

    useGlobalPkgs = true;
    #useUserPackages = true;
    verbose = true;
    extraSpecialArgs = { inherit inputs; };
  };

  security.sudo.wheelNeedsPassword = true;
  security.pam.enableSSHAgentAuth = true;

  virtualisation.docker = {
    enable = true;
    enableNvidia = true;
  };

  services.minidsp = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    #inputs.minidsp.packages.${system}.default

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
    virt-manager
    distrobox
  ];

  services.vscode-server.enable = true;
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  services.rpcbind.enable = true;

  services.tailscale.enable = true;
  networking.firewall.checkReversePath = "loose";


  virtualisation.containerd.enable = true;
  virtualisation.libvirtd.enable = true;

  #services.resolved.enable = true;

  #environment.etc."systemd/resolved.conf.d/minikube.conf".text = ''
  #[Resolve]
  #DNS=10.96.0.10
  #Domains=~cluster.local
  #'';
  networking.firewall.allowedTCPPorts = [ 8501 ];
  networking.hosts = {
    "10.101.39.89" = [ "istio-ingressgateway.istio-system.svc.cluster.local" ];
  };

  programs.command-not-found.enable = false;

  # Allow running aarch64 binaries 
  boot.binfmt.emulatedSystems = [ "aarch64-linux" "armv6l-linux" ];
  nix.settings.substituters = [ "https://cache.armv7l.xyz" ];
  nix.settings.trusted-public-keys = [ "cache.armv7l.xyz-1:kBY/eGnBAYiqYfg0fy0inWhshUo+pGFM3Pj7kIkmlBk=" ];


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
