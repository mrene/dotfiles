{ inputs, ... }:
{
  flake.modules.nixos.beast =
    {
      lib,
      config,
      common,
      pkgs,
      inputs,
      self,
      ...
    }:
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
        inputs.determinate.nixosModules.default
      ];

      # Increase nixos-rebuild build-vm memory size
      virtualisation.vmVariant.virtualisation.memorySize = 16384; # MB

      # Sops secrets (services-sops aspect provides base config)
      sops.secrets."home-assistant/token" = {
        owner = config.users.users.mrene.name;
      };

      programs.corefreq.enable = true;

      # Restic backups (services-restic aspect is imported in default.nix)
      homelab.backups = {
        enable = true;
        paths = [
          "/home/mrene/logseq"
          "/var/lib/thread"
        ];
      };

      # Fixes: warning: download buffer is full; consider increasing the 'download-buffer-size' setting
      nix.settings = {
        download-buffer-size = 524288000; # 500 MiB
        eval-cores = 0;
        extra-experimental-features = [ "parallel-eval" ];
      };


      # Reset miniDSP volume to 100% so we have enough headroom
      systemd.services.minidsp-amixer-volume =
        let
          minidsp-amixer-volume = pkgs.writeShellApplication {
            name = "minidsp-amixer-volume";
            runtimeInputs = [
              pkgs.alsa-utils
              pkgs.gawk
            ];
            text = ''
              sleep 2  # Wait for ALSA to detect the card
              card=$(awk '/miniDSP/ {print $1; exit}' /proc/asound/cards || true)
              if [ -n "$card" ]; then
                amixer -c "$card" set 'miniDSP Flex' 100%
              fi
            '';
          };
        in
        {
          description = "Set miniDSP volume using amixer";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${lib.getExe minidsp-amixer-volume}";
          };
          wantedBy = [ "multi-user.target" ];
        };

      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 4d --keep 3 --nogcroots";
      };

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
      boot.kernelParams = [ ];

      swapDevices = [
        {
          device = "/swap";
          size = 65536;
        }
      ];

      # hardware-brightness aspect is imported in default.nix
      boot.kernelModules = [ "nct6775" ];

      networking.networkmanager.enable = true;
      networking.hostName = "beast";

      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          libva-vdpau-driver
          libvdpau-va-gl
          vulkan-tools
          vulkan-caps-viewer
          vulkan-hdr-layer-kwin6
          vulkan-validation-layers
          nvidia-vaapi-driver
        ];
      };
      services.xserver.enable = true;
      services.xserver.videoDrivers = [ "nvidia" ];
      nixpkgs.config.cudaSupport = true;

      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = false;
        pulse.enable = true;
        jack.enable = true;
      };

      hardware.openrazer = {
        enable = true;
        users = [ "mrene" ];
      };

      users = {
        users = {
          mrene = {
            isNormalUser = true;
            description = "mathieu";
            extraGroups = [
              "networkmanager"
              "wheel"
              "docker"
              "dialout"
              "plugdev"
            ];
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
        users.mrene = {
          imports = with self.modules.homeManager; [
            # Core
            core-minimal
            core-ssh

            # Shell
            shell-fish
            shell-fish-ai
            shell-wezterm
            shell-zellij

            # Dev
            dev-git
            dev-jujutsu

            # Desktop
            desktop-gnome
            desktop-rofi

            # System
            system-common
            system-neofetch

            # Host-specific
            beast
          ];
        };
        useGlobalPkgs = true;
        verbose = true;
        extraSpecialArgs = { inherit inputs self; };
      };

      security.sudo.wheelNeedsPassword = true;
      security.pam.sshAgentAuth.enable = true;
      services.openssh.authorizedKeysFiles = lib.mkForce [ "/etc/ssh/authorized_keys.d/%u" ];

      virtualisation.docker.enable = true;
      hardware.nvidia-container-toolkit = {
        enable = true;
        suppressNvidiaDriverAssertion = true;
      };

      services.minidsp.enable = true;

      environment.systemPackages = with pkgs; [
        logseq
        zotero
        roomeqwizard
        spotify
        alsa-utils
        ddcutil
        ddcui
        openrazer-daemon
        nvtopPackages.nvidia
        nvitop
        virt-manager
        distrobox
        nvme-cli
        sysstat
        dool
        virtiofsd
      ];

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

      networking.firewall.enable = false;
      networking.firewall.allowedTCPPorts = [ 8501 ];
      networking.hosts = {
        "192.168.1.10" = [ "localhost.humanfirst.ai" ];
        "127.0.0.1" = [ "istio-ingressgateway.istio-system.svc.cluster.local" ];
      };

      programs.command-not-found.enable = false;
      # hardware-screen-switch aspect is imported in default.nix

      boot.binfmt.emulatedSystems = [
        "aarch64-linux"
        "armv6l-linux"
      ];

      system.stateVersion = "22.11";
    };
}
