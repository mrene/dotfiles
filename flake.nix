{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.11";
    nixpkgsUnstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    minidsp = {
      url = "github:mrene/minidsp-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devenv.url = "github:cachix/devenv/v0.5";
  };

  # the @ operator binds the left side attribute set to the right side
  # `inputs` can still be referenced, but `darwin` is bound to `inputs.darwin`, etc.
  outputs = inputs @ { self, flake-utils, darwin, deploy-rs, nixpkgs, nixpkgsUnstable, home-manager, ... }:

    # eachDefaultSystem basically replicates each attribute so it also exists as `<attr>.<system>`, any override can be done later using `//` to concat the attr sets
    # example: 
    # inputs.flake-utils.lib.eachDefaultSystem(f: { a = 42;})
    # { a = { aarch64-darwin = 42; aarch64-linux = 42; i686-linux = 42; x86_64-darwin = 42; x86_64-linux = 42; }; }
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config = {
              permittedInsecurePackages = [
                "python3.10-poetry-1.2.2" # CVE-2022-42966 - Regex DoS
              ];
            };
          };
          pkgsUnstable = import nixpkgsUnstable { inherit system; };
        in
        {

          devShell = with pkgs; pkgs.mkShell {
            buildInputs = [
              # Just in case :)
            ];
          };

        })
    // # <- concatenates Nix attribute sets
    (
      let
        pkgsConfig = {
          permittedInsecurePackages = [
            "python3.10-poetry-1.2.2" # CVE-2022-42966 - Regex DoS
          ];
        };
      in
      {
        homeConfigurations = {
          "mrene@beast" = inputs.home-manager.lib.homeManagerConfiguration {
            # pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
            pkgs = import nixpkgs {
              system = "x86_64-linux";
              config = pkgsConfig;
            };
            modules = [
              ./nixpkgs/home-manager/beast.nix
              ({ pkgs, ... }: {
                home.packages = [
                  inputs.minidsp.packages.${pkgs.system}.default
                  inputs.devenv.packages.${pkgs.system}.devenv
                ];
              })
            ];
            # extraSpecialArgs = { 
            #   pkgsUnstable = inputs.nixpkgs.legacyPackages.aarch64-darwin;
            # };
          };

          "mrene@utm" = inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              system = "aarch64-linux";
              config = pkgsConfig;
            };
            modules = [
              ./nixpkgs/home-manager/utm.nix
              ({ pkgs, ... }: {
                home.packages = [
                  inputs.minidsp.packages.${pkgs.system}.default
                  inputs.devenv.packages.${pkgs.system}.devenv
                ];
              })
            ];
            # extraSpecialArgs = { 
            #   pkgsUnstable = inputs.nixpkgs.legacyPackages.aarch64-darwin;
            # };
          };

          "mrene@Mathieus-MBP" = inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              system = "aarch64-darwin";
              config = pkgsConfig;
            };
            modules = [
              ./nixpkgs/home-manager/mac.nix
            ];
            # extraSpecialArgs = { pkgsUnstable = inputs.nixpkgs.legacyPackages.aarch64-darwin; };
          };
        };

        darwinConfigurations = {
          # nix build .#darwinConfigurations.mbp2021.system
          # ./result/sw/bin/darwin-rebuild switch --flake .
          Mathieus-MBP = darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            modules = [
              ./nixpkgs/darwin/mbp2021/configuration.nix
              home-manager.darwinModules.home-manager
              {
                # `home-manager` config
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.verbose = true;
                home-manager.users.mrene = import ./nixpkgs/home-manager/mac.nix;
              }
            ];
            inputs = { inherit darwin nixpkgs; };
          };
        };

        nixosConfigurations = {
          # sudo nixos-rebuild switch --flake .#homepi
          homepi = inputs.nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            specialArgs = { common = self.common; inherit inputs; };
            modules = [ ];
          };

          # sudo nixos-rebuild switch --flake .#utm
          utm = inputs.nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            specialArgs = { common = self.common; inherit inputs; };
            modules = [
              ./nixpkgs/nixos/utm/configuration.nix
              home-manager.nixosModules.home-manager
              {
                # `home-manager` config
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.verbose = true;
                home-manager.users.mrene = import ./nixpkgs/home-manager/utm.nix;
              }
            ];

          };
        };

        images = {
          # nix build .#images.homepi
          homepi = self.nixosConfigurations.homepi.config.system.build.sdImage;
        };

        common = {
          sshKeys = [
            "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBMDK9LCwU62BIcyn73TcaQlMqr12GgYnHYcw5dbDDNmYnpp2n/jfDQ5hEkXd945dcngW6yb7cmgsa8Sx9T1Uuo4= secretive@mbp2021"
          ];
        };
      }
    );
}
