{ pkgs, config, lib, inputs, ... }:
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  # environment.systemPackages =
  #   [ pkgs.vim
  #   ];

  imports = [
    inputs.home-manager.darwinModules.home-manager
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
    auto-optimise-store = true

    # assuming the builder has a faster internet connection
    builders-use-substitutes = true

    experimental-features = nix-command flakes
  '';

  # nix = {
  #   buildMachines = lib.filter (x: x.hostName != config.networking.hostName) [
  #     {
  #       systems = [ "aarch64-linux" "x86_64-linux" ];
  #       sshUser = "root";
  #       maxJobs = 4;
  #       # relies on `/var/root/.ssh/nix-builder` key to be there
  #       # TODO set this up via nix
  #       hostName = "oracle-nix-builder";
  #       supportedFeatures = [ "nixos-test" "benchmark" "kvm" "big-parallel" ];
  #     }
  #   ];
  #   distributedBuilds = config.nix.buildMachines != [ ];
  # };

  # Setup 1Password CLI `op`
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "1password-cli"
  ];

  system.activationScripts.extraActivation.text = ''
    # For TouchID to work in `op` 1Password CLI, it needs to be at `/usr/local/bin`
    # (Hopefully this requirement will be lifted by 1Password at some point)
    # NOTE we don't install `op` via nix but simply copy the binary
    cp ${pkgs._1password}/bin/op /usr/local/bin/op
  '';

  security.pam.enableSudoTouchIdAuth = true;

  programs = {
    fish.enable = true;
  };

  environment.shells = [ pkgs.fish ];

  users.users.mrene = {
    home = "/Users/mrene";
    shell = "${pkgs.fish}/bin/fish";
  };

  home-manager = {
    users.mrene = import ../../home-manager/mac.nix;

    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;
  };

  users.users.root = {
    home = "/var/root";
    shell = "${pkgs.fish}/bin/fish";
  };

  system.stateVersion = 4;
}
