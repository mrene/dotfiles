{ inputs, ... }:
{
  flake.modules.darwin.mbp2021 =
    {
      lib,
      pkgs,
      inputs,
      self,
      ...
    }:
    let
      flakes = lib.filterAttrs (_: v: (v._type or "") == "flake") inputs;
    in
    {
      nixpkgs.hostPlatform = "aarch64-darwin";
      homelab.fonts.enable = true;
      homelab.tailscale-networking.enable = true;

      environment.systemPackages = with pkgs; [
        fish
        bandwhich
        nixos-rebuild
        pkg-config
        wezterm
      ];

      nixpkgs.flake = {
        setNixPath = false;
        setFlakeRegistry = false;
      };

      nix = {
        enable = true;
        settings = {
          experimental-features = [
            "flakes"
            "nix-command"
          ];
          auto-optimise-store = false;
          extra-platforms = "x86_64-darwin";
          trusted-public-keys = [
            "utm:TNhc0y1cxi+iR7IgKFRUTkXkEf6lzRqhTyk7Nl03Piw="
            "beast:CO98mFl5tv8ky4Msn/ftNi3WK+PW1y3Xm1BUkT2L7yY="
            "nas:AKbMvZhFWLMEqMCt9TLcN7Ha62q9jf4+XhHH3VVO+kI="
            "nas:bSV2Y2BE5ee3JToAg08jZ+DojOt1Yq/EFlw93RZHh8Q="
          ];
          trusted-users = [ "@admin" ];
        };

        linux-builder = {
          enable = false;
          ephemeral = true;
          maxJobs = 4;
        };

        registry = lib.mapAttrs (_: flake: { inherit flake; }) flakes;
        nixPath = lib.mapAttrsToList (x: _: "${x}=flake:${x}") flakes;

        extraOptions = ''
          keep-outputs = true
          keep-derivations = true
          builders-use-substitutes = true
          experimental-features = nix-command flakes
        '';
      };

      system.activationScripts.extraActivation.text = ''
        cp ${pkgs._1password-cli}/bin/op /usr/local/bin/op
      '';

      security.pam.services.sudo_local.touchIdAuth = true;
      programs.fish.enable = true;

      environment.shells = [ pkgs.fish ];
      system.primaryUser = "mrene";
      users.users.mrene = {
        home = "/Users/mrene";
        shell = "${pkgs.fish}/bin/fish";
      };

      home-manager = {
        users.mrene = self.modules.homeManager.mbp2021;
        useGlobalPkgs = true;
        verbose = true;
        backupFileExtension = "bak";
      };

      users.users.root = {
        home = "/var/root";
        shell = "${pkgs.fish}/bin/fish";
      };

      system.stateVersion = 4;
    };
}
