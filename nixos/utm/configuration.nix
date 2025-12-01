# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').
{
  lib,
  pkgs,
  common,
  inputs,
  self,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.vscode-server.nixosModule

    inputs.nixos-lima.nixosModules.lima
    inputs.nixos-lima.nixosModules.disk-default
    inputs.nixos-lima.nixosModules.impure-config
    inputs.nixos-lima.nixosModules.lima-container

    # Include the results of the hardware scan.
    #./hardware-configuration.nix
  ];

  lima.settings = {
    ssh.localPort = 2222;
    memory = "16GB";
    cpus = 8;
    disk = "128GB";
  };

  lima.user = {
    name = "mrene";
    sshPubKey = lib.mkForce "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBMDK9LCwU62BIcyn73TcaQlMqr12GgYnHYcw5dbDDNmYnpp2n/jfDQ5hEkXd945dcngW6yb7cmgsa8Sx9T1Uuo4=";
  };

  documentation.enable = false;

  # Enable refactored homelab modules
  homelab.vm-common.enable = true;
  homelab.ssh-ca.enable = true;
  homelab.common-packages.enable = true;
  homelab.fonts.enable = true;
  homelab.minikube.enable = true;
  homelab.vm.common.enable = true;
  environment.systemPackages = [ pkgs.nix-output-monitor ];
  # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;
  # boot.kernelParams = ["console=tty0"];
  # boot.loader.timeout = 5;

  # Mount shared filesystem
  #fileSystems."/host" = {
  #device = "share";
  #fsType = "9p";
  #options = ["trans=virtio" "version=9p2000.L" "cache=loose"];
  #};

  users.users.root.openssh.authorizedKeys.keys = common.builderKeys ++ common.sudoSshKeys;
  users.users.mrene.openssh.authorizedKeys.keys =
    common.builderKeys ++ common.sudoSshKeys ++ common.sshKeys;

  networking.hostName = "utm";
  # networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  networking.firewall.enable = false;

  # services.xserver.enable = true;
  services.tailscale.enable = true;

  home-manager = {
    users.mrene = {
      imports = [
        self.modules.homeManager.all
        ../../home-manager/utm.nix
      ];
    };

    useGlobalPkgs = true;
    #useUserPackages = true;
    verbose = true;
    extraSpecialArgs = { inherit inputs self; };
  };

  # Sign store builds for sharing across network
  # nix.settings.secret-key-files = "/var/secrets/cache-priv-key.pem";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
