inputs@{ flake-parts, import-tree, flake-aspects, flake-file, ... }:
let
  imports = [
    # Declare global/infrastructure inputs for flake-file
    {
      flake-file = {
        nixConfig = {
          extra-substituters = [ "https://nixos-raspberrypi.cachix.org" ];
          extra-trusted-public-keys = [
            "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
          ];
        };

        inputs = {
          # Core
          nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
          home-manager = {
            url = "github:nix-community/home-manager/release-25.11";
            inputs.nixpkgs.follows = "nixpkgs";
          };
          darwin = {
            url = "github:lnl7/nix-darwin/master";
            inputs.nixpkgs.follows = "nixpkgs";
          };
          sops-nix = {
            url = "github:Mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs";
          };

          # Flake infrastructure
          flake-parts.url = "github:hercules-ci/flake-parts";
          import-tree.url = "github:vic/import-tree";
          flake-aspects.url = "github:vic/flake-aspects";
          flake-file.url = "github:vic/flake-file";
          flake-compat = {
            url = "https://git.lix.systems/lix-project/flake-compat/archive/main.tar.gz";
            flake = false;
          };

          # Clan
          clan-core = {
            url = "https://git.clan.lol/clan/clan-core/archive/main.tar.gz";
            inputs.nixpkgs.follows = "nixpkgs";
            inputs.flake-parts.follows = "flake-parts";
            inputs.nix-darwin.follows = "darwin";
          };

          # Determinate (top-level)
          determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
        };
      };
    }
    { flake.flakeModules.default = { inherit imports; }; }
    flake-parts.flakeModules.modules
    flake-aspects.flakeModule
    flake-file.flakeModules.default
    inputs.clan-core.flakeModules.default
    ./packages.nix
    ./overlays
    (import-tree ./aspects)
    (import-tree ./hosts)
    ./devshell.nix
    ./common.nix
    (
      { config, ... }:
      let
        allTopLevels = (
          inputs.nixpkgs.lib.mapAttrsToList (
            k: v: v.config.system.build.toplevel.drvPath
          ) config.flake.nixosConfigurations
        );
      in
      {
        flake.nixosConfigurations' = builtins.parallel allTopLevels (
          config.flake.nixosConfigurations.beast.pkgs.symlinkJoin {
            name = "all";
            paths = allTopLevels;
          }
        );
      }
    )
  ];
in
flake-parts.lib.mkFlake { inherit inputs; } {
  inherit imports;
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ];
}
