{ pkgs, config, lib, inputs, ... }:
{
  imports = [
    ../../common/fonts.nix
  ];

  environment.systemPackages = with pkgs; [
    fish
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = [ "flakes" "nix-command" ];
      auto-optimise-store = true;
    };

    registry = {
      nixpkgs.flake = inputs.nixpkgs;
    };
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      auto-optimise-store = true

      # assuming the builder has a faster internet connection
      builders-use-substitutes = true

      experimental-features = nix-command flakes
    '';
  };

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
  fonts.fontDir.enable = true;

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