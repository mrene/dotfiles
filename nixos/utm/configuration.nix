# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  common,
  inputs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.vscode-server.nixosModule

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../common/minikube.nix
    ../common/gui/desktop.nix
    ../common/common.nix
    ../common/packages.nix
    ../common/vm/common.nix
    ../common/gui/base.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = ["console=tty0"];
  boot.loader.timeout = 5;

  # Mount shared filesystem
  #fileSystems."/host" = {
    #device = "share";
    #fsType = "9p";
    #options = ["trans=virtio" "version=9p2000.L" "cache=loose"];
  #};

  users.users.root.openssh.authorizedKeys.keys = common.builderKeys;

  networking.hostName = "utm";
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  services.xserver.enable = true;
  services.tailscale.enable = true;

  virtualisation.docker = {
    enable = true;
  };

  home-manager = {
    users.mrene = import ../../home-manager/utm.nix;

    useGlobalPkgs = true;
    #useUserPackages = true;
    verbose = true;
    extraSpecialArgs = {inherit inputs;};
  };

  # Sign store builds for sharing across network
  nix.settings.secret-key-files = "/var/secrets/cache-priv-key.pem";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
