{
  lib,
  pkgs,
  inputs,
  ...
}: 
let
  flakes = lib.filterAttrs (_: v: (v._type or "") == "flake") inputs;
in
{
  imports = [
    ../../common/fonts.nix
  ];

  environment.systemPackages = with pkgs; [
    fish
    bandwhich
    nixos-rebuild
    pkg-config
  ];

  # Auto upgrade nix package and the daemon service.

  # Disable automatically setting the flake registry entry for nixpkgs
  # because it's already being done and conflicts with it.
  nixpkgs.flake = {
    setNixPath = false;
    setFlakeRegistry = false;
  };

  nix = {
    enable = true;
    # package = pkgs.nixVersions.nix_2_22;
    settings = {
      experimental-features = ["flakes" "nix-command"];
      # Disable since it causes issues
      # https://github.com/NixOS/nix/issues/7273
      # "error: cannot link '/nix/store/.tmp-link' to '/nix/store/.links/...': File exists"
      auto-optimise-store = false;
      extra-platforms = "x86_64-darwin";
      trusted-public-keys = [
        "utm:TNhc0y1cxi+iR7IgKFRUTkXkEf6lzRqhTyk7Nl03Piw=" # aarch64 builds on laptop vm
        "beast:CO98mFl5tv8ky4Msn/ftNi3WK+PW1y3Xm1BUkT2L7yY="
        "nas:AKbMvZhFWLMEqMCt9TLcN7Ha62q9jf4+XhHH3VVO+kI="
      ];

      # This line is a prerequisite
      trusted-users = [ "@admin" ];
    };

    linux-builder = {
      enable = true;
      ephemeral = true;
      maxJobs = 4;
      #config = {
        #virtualisation = {
          #darwin-builder = {
            #diskSize = 40 * 1024;
            #memorySize = 8 * 1024;
          #};
          #cores = 6;
        #};
      #};
    };


    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakes;
    nixPath = lib.mapAttrsToList (x: _: "${x}=flake:${x}") flakes;

    extraOptions = ''
      keep-outputs = true
      keep-derivations = true

      # assuming the builder has a faster internet connection
      builders-use-substitutes = true

      experimental-features = nix-command flakes
    '';
  };

  system.activationScripts.extraActivation.text = ''
    # For TouchID to work in `op` 1Password CLI, it needs to be at `/usr/local/bin`
    # (Hopefully this requirement will be lifted by 1Password at some point)
    # NOTE we don't install `op` via nix but simply copy the binary
    cp ${pkgs._1password-cli}/bin/op /usr/local/bin/op
  '';

  security.pam.services.sudo_local.touchIdAuth = true;

  programs = {
    fish.enable = true;
  };

  environment.shells = [pkgs.fish];
  system.primaryUser = "mrene";
  users.users.mrene = {
    home = "/Users/mrene";
    shell = "${pkgs.fish}/bin/fish";
  };

  home-manager = {
    users.mrene = import ../../home-manager/mac.nix;
    useGlobalPkgs = true;
    verbose = true;
    #cuases the profile not to link to ~/.nix-profile/bin (would need to adjust fish paths)
    #useUserPackages = true;
    # Passed from flake to avoid infinite recursion issue:
    #extraSpecialArgs = { inherit inputs; };
  };

  users.users.root = {
    home = "/var/root";
    shell = "${pkgs.fish}/bin/fish";
  };

  system.stateVersion = 4;
}
