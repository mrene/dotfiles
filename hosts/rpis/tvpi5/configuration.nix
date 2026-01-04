{ inputs, ... }:
{
  flake.modules.nixos.tvpi =
    {
      lib,
      config,
      pkgs,
      common,
      inputs,
      ...
    }:
    {
      # Override the kernel package to use the upstream nixos-raspberrypi prebuilt kernel
      boot.kernelPackages =
        inputs.nixos-raspberrypi-nofollows.packages.${pkgs.stdenv.hostPlatform.system}.linuxPackages_rpi5;
      hardware.enableRedistributableFirmware = true;
      services.openssh.enable = true;
      services.openssh.settings.PasswordAuthentication = false;

      sops.secrets."home-assistant/token" = {
        owner = config.users.users.mrene.name;
      };

      networking = {
        hostName = "tvpi";
        usePredictableInterfaceNames = false;
        interfaces.eth0.ipv4.addresses = [
          {
            address = "192.168.1.245";
            prefixLength = 24;
          }
        ];
        defaultGateway = {
          address = "192.168.1.1";
          interface = "eth0";
        };
        nameservers = [
          "1.1.1.1"
          "8.8.8.8"
        ];
      };

      # Enable nvme ssd
      hardware.raspberry-pi.config.all.base-dt-params = {
        pciex1.enable = true;
      };

      users.users.root.openssh.authorizedKeys.keys =
        common.builderKeys ++ common.sudoSshKeys ++ common.sshKeys;
      users.defaultUserShell = pkgs.fish;
      programs.fish.enable = true;

      users.users.mrene = {
        isNormalUser = true;
        home = "/home/mrene";
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = common.sshKeys;
      };

      hardware.bluetooth.enable = true;

      networking.firewall.enable = false;
      services.tailscale = {
        enable = true;
        extraUpFlags = [ "--advertise-exit-node" ];
      };

      system.stateVersion = "25.11";
    };
}
