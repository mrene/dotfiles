{
  lib,
  pkgs,
  inputs,
  ...
}: let
  flakes = lib.filterAttrs (_: v: (v._type or "") == "flake") inputs;
in {
  imports = [
    ./ssh-ca.nix
  ];

  nix = {
    package = pkgs.nixVersions.latest; # or versioned attributes like nix_2_4
    settings = {
      experimental-features = ["flakes" "nix-command" "fetch-closure"];
      auto-optimise-store = true;
      keep-outputs = true;
      keep-derivations = true;
      trusted-users = ["@wheel"];

      # To generate:
      # nix-store --generate-binary-cache-key builder-name /var/secrets/nix-builder.pem /var/secrets/nix-builder.pub
      # Add to the machine's config: nix.settings.secret-key-files = "/var/secrets/nix-builder.pem";
      # Add contents of public key to this list
      trusted-public-keys = [
        "utm:TNhc0y1cxi+iR7IgKFRUTkXkEf6lzRqhTyk7Nl03Piw=" # aarch64 builds on laptop vm
        "beast:CO98mFl5tv8ky4Msn/ftNi3WK+PW1y3Xm1BUkT2L7yY="
        "nas:AKbMvZhFWLMEqMCt9TLcN7Ha62q9jf4+XhHH3VVO+kI="
      ];
    };

    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakes;
    nixPath = lib.mapAttrsToList (x: _: "${x}=flake:${x}") flakes;
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocales = [ "en_GB.UTF-8/UTF-8" ];
#  en_GB.UTF-8/UTF-8

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  programs.fish.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # Some programs (ex: Go) expects /etc/mime.types
  environment.etc."mime.types".source = "${pkgs.mailcap}/etc/mime.types";

  networking.firewall.rejectPackets = true;

  # Trim SSD weekly
  services.fstrim.enable = true;

  services.avahi = {
    enable = true;
    ipv4 = true;
    ipv6 = true;

    # Hook into NSS in order for apps to resolve .local domains
    nssmdns4 = true;
    nssmdns6 = true;

    publish = {
      addresses = true;
      userServices = true;
      workstation = true;
      enable = true;
    };

  };
}
