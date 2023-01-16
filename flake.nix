{
  inputs = {
    # Package channels
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.11";
    nixpkgsUnstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    # Nix tools
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Generate vm images and initial boot media
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      #url = "/home/mrene/dev/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # flake-utils.url = "github:numtide/flake-utils";
    # deploy-rs = {
    #   url = "github:serokell/deploy-rs";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Packages sources from other flakes
    minidsp = {
      url = "github:mrene/minidsp-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devenv.url = "github:cachix/devenv/v0.5";

    # NixOS fix so that vscode-server can run correctly
    vscode-server = {
      url = "github:msteen/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # the @ operator binds the left side attribute set to the right side
  # `inputs` can still be referenced, but `darwin` is bound to `inputs.darwin`, etc.
  outputs = inputs @ { self, darwin, nixpkgs, nixpkgsUnstable, home-manager, vscode-server, nixos-generators, ... }:
    (
      let
        pkgsConfig = {
          permittedInsecurePackages = [
            "python3.10-poetry-1.2.2" # CVE-2022-42966 - Regex DoS
          ];
          allowUnfree = true;
        };

        # Overlay adding flake inputs inside `pkgs`
        packageOverlay = final: prev: {
          minidsp = inputs.minidsp.packages.${prev.system}.default;
          devenv = inputs.devenv.packages.${prev.system}.devenv;
        };

        packageOverlays = [
          packageOverlay
          (import ./nixpkgs/overlays/vscode-with-extensions.nix)
        ];

        homeManagerConfig = path: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.verbose = true;
            home-manager.users.mrene = import path;
        };
      in
      {
        homeConfigurations = {
          "mrene@beast" = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              system = "x86_64-linux";
              config = pkgsConfig;
              overlays = packageOverlays;
            };
            modules = [ ./nixpkgs/home-manager/beast.nix ];
          };

          "mrene@utm" = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              system = "aarch64-linux";
              config = pkgsConfig;
              overlays = packageOverlays;
            };
            modules = [ ./nixpkgs/home-manager/utm.nix ];
          };

          "mrene@Mathieus-MBP" = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              system = "aarch64-darwin";
              config = pkgsConfig;
              overlays = packageOverlays;
            };
            modules = [ ./nixpkgs/home-manager/mac.nix ];
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
              (homeManagerConfig ./nixpkgs/home-manager/mac.nix)
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
            pkgs = import nixpkgs {
              system = "aarch64-linux";
              config = pkgsConfig;
              overlays = packageOverlays;
            };
            specialArgs = { common = self.common; inherit inputs; };
            modules = [
              ./nixpkgs/nixos/utm/configuration.nix
              home-manager.nixosModules.home-manager
              (homeManagerConfig ./nixpkgs/home-manager/utm.nix)
              vscode-server.nixosModule
            ];
          };

          # sudo nixos-rebuild switch --flake .#qemu
          qemu = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            pkgs = import nixpkgs {
              system = "x86_64-linux";
              config = pkgsConfig;
              overlays = packageOverlays;
            };
            specialArgs = { common = self.common; inherit inputs; };
            modules = [
              ./nixpkgs/nixos/qemu/configuration.nix
              home-manager.nixosModules.home-manager
              (homeManagerConfig ./nixpkgs/home-manager/utm.nix)
              vscode-server.nixosModule
            ];
          };
        };


        # Prepares a qemu script that launches the root FS from the host nix store, for quick tests
        vm = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config = pkgsConfig;
            overlays = packageOverlays;
          };
          specialArgs = { common = self.common; inherit inputs; };
          modules = [
            ./nixpkgs/nixos/utm/configuration.nix
            home-manager.nixosModules.home-manager
            (homeManagerConfig ./nixpkgs/home-manager/utm.nix)
            vscode-server.nixosModule
          ];
          format = "vm";
        };

        images = {
          # nix build .#images.homepi
          homepi = self.nixosConfigurations.homepi.config.system.build.sdImage;
        };

        common = {
          sshKeys = [
            "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBMDK9LCwU62BIcyn73TcaQlMqr12GgYnHYcw5dbDDNmYnpp2n/jfDQ5hEkXd945dcngW6yb7cmgsa8Sx9T1Uuo4= secretive@mbp2021"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAeSvwegmfet4Rw8OBFEVUfx+5WmVcYR4/n20QSh4tAs mrene@beast"
          ];
        };
      }
    );
}
