{ pkgs, inputs, ... }:

{
  nix = {
    package = pkgs.nixUnstable; # or versioned attributes like nix_2_4
    settings = {
      experimental-features = [ "flakes" "nix-command" ];
      auto-optimise-store = true;
      keep-outputs = true;
      keep-derivations = true;
      trusted-users = [ "@wheel" ];
      trusted-public-keys = [
        "utm:TNhc0y1cxi+iR7IgKFRUTkXkEf6lzRqhTyk7Nl03Piw=" # aarch64 builds on laptop vm
        "beast:CO98mFl5tv8ky4Msn/ftNi3WK+PW1y3Xm1BUkT2L7yY="
      ];
    };

    registry = {
      self.flake = inputs.self;
      nixpkgs.flake = inputs.nixpkgs;
    };

  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
