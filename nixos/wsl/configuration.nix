
# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ../common/common.nix
    ../common/packages.nix
    ../common/distributed-build.nix
    ../modules

    # include NixOS-WSL modules
    inputs.nixos-wsl.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
  ];

  wsl.enable = true;
  wsl.defaultUser = "mrene";
  # Use OpenGL drivers from Windows
  wsl.useWindowsDriver = true;

  # https://github.com/nix-community/NixOS-WSL/issues/454#issuecomment-2059795181
  hardware.graphics = {
    enable = true;

    extraPackages = with pkgs; [
      mesa
      libvdpau-va-gl
    ];
  };

  users.defaultUserShell = pkgs.fish;

  programs.nix-ld  = {
    enable = true;
  };
  environment.variables = {
    NIX_LD_LIBRARY_PATH = lib.mkForce "/run/current-system/sw/share/nix-ld/lib:/usr/lib/wsl/lib";
  };

  home-manager = {
    users.mrene = import ../../home-manager/wsl.nix;

    useGlobalPkgs = true;
    verbose = true;
    extraSpecialArgs = {inherit inputs;};
    backupFileExtension = "hmbak";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
