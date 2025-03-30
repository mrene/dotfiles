# edit this configuration file to define what should be installed on
# your system.  help is available in the configuration.nix(5) man page
# and in the nixos manual (accessible by running ‘nixos-help’).
{
  lib,
  config,
  common,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.vscode-server.nixosModule

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
    ../modules
  ];

  homelab.sops.enable = true;
  sops.secrets."home-assistant/token" = {
    owner = config.users.users.mrene.name;
  };

  programs.corefreq.enable = true;

  homelab.backups = {
    enable = true;
    paths = [
      "/home/mrene/logseq"
      "/var/lib/thread"
    ];
  };

  homelab.dyndns.enable = true;

   services.openthread-border-router = {
     enable = false;
     backboneInterface = "enp36s0";
     logLevel = "debug";
     radio =  {
       device = "/dev/serial/by-path/pci-0000:30:00.3-usb-0:4:1.0-port0";
       baudRate = 460800;
       extraDevices = [ "trel://enp36s0" ];
     };
     rest = {
       listenPort = 58081;
     };
   };

  programs.nh = {
    enable = true;
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
  boot.kernelParams = [];

  swapDevices = [{ device = "/swap"; size = 65536; }];

  #boot.kernelPackages = pkgs.linuxPackages_6_11;
  
  # Expose external monitor brightness control
  hardware.ddcci.enable = true;

  # Sensors
  boot.kernelModules = ["nct6775"];

  networking.networkmanager.enable = true;
  networking.hostName = "beast";

  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
      vulkan-tools
    ];
  };
  services.xserver.enable = true;
  services.xserver.videoDrivers = ["nvidia"];
  nixpkgs.config.cudaSupport = true;

  # Enable sound with pipewire.
  #sound.enable = true;
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
    users = ["mrene"];
    batteryNotifier.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    users = {
      mrene = {
        isNormalUser = true;
        description = "mathieu";
        extraGroups = ["networkmanager" "wheel" "docker" "dialout" "plugdev"];
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
    extraSpecialArgs = {inherit inputs;};
  };

  security.sudo.wheelNeedsPassword = true;
  security.pam.sshAgentAuth.enable = true;
  # Prevent authorized keys from containing files in the user directory, as they could be
  # used to escalate privileges to root.
  services.openssh.authorizedKeysFiles = lib.mkForce ["/etc/ssh/authorized_keys.d/%u"];

  virtualisation.docker.enable = true;
  hardware.nvidia-container-toolkit.enable = true;

  services.minidsp = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    #inputs.minidsp.packages.${system}.default

    (builtins.fetchClosure {
      fromPath = "/nix/store/hsb5d1cqfqqnr902kj8da9s0hq6q7kqj-logseq-0.10.9";
      fromStore = "https://cache.nixos.org";
      inputAddressed = true;
    })
    zotero

    #Audio
    roomeqwizard
    spotify
    audacity

    # HW support
    #razergenie #mouse
    openrazer-daemon

    nvtopPackages.nvidia # htop-like gpu load viewer
    nvitop
    virt-manager
    distrobox
    nvme-cli
    sysstat
    dool
    virtiofsd
    home-assistant-cli
  ];



  #services.vscode-server.enable = true;
  programs.nix-ld.enable = true;

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  services.rpcbind.enable = true;

  services.tailscale = {
    enable = true;
    extraUpFlags = [ "--advertise-exit-node" ];
    useRoutingFeatures = "server";
  };
  networking.firewall.checkReversePath = "loose";

  virtualisation.containerd.enable = true;
  virtualisation.libvirtd.enable = true;

  #services.resolved.enable = true;

  #environment.etc."systemd/resolved.conf.d/minikube.conf".text = ''
  #[Resolve]
  #DNS=10.96.0.10
  #Domains=~cluster.local
  #'';
  networking.firewall.enable = false;
  networking.firewall.allowedTCPPorts = [8501];
  networking.hosts = {
    "192.168.1.10" = ["localhost.humanfirst.ai"];
    "127.0.0.1" = ["istio-ingressgateway.istio-system.svc.cluster.local"];
  };

  programs.command-not-found.enable = false;

  # Allow running aarch64 binaries
  boot.binfmt.emulatedSystems = ["aarch64-linux" "armv6l-linux"];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
