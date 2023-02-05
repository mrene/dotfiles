{
  inputs = {
    # Package channels
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgsUnstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Nix tools
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland/main";
      # Following nixpkgs would not use pre-built binaries from the cachix cache 
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    # Generate vm images and initial boot media
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      #url = "/home/mrene/dev/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
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
  outputs = inputs @ { self, darwin, nixpkgs, nixpkgsUnstable, home-manager, vscode-server, nixos-generators, hyprland, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem
      (system: (
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        {
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              nixos-generators.packages.${system}.nixos-generate
              nixos-install-tools
            ];
          };
        }
      )) //
    (
      let
        pkgsConfig = {
          permittedInsecurePackages = [
            "python3.10-poetry-1.2.2" # CVE-2022-42966 - Regex DoS
            "electron-19.0.7" # EOL, but many deps are still using it
          ];

          allowUnfree = true;
        };

        # Overlay adding flake inputs inside `pkgs`
        packageOverlay = final: prev: {
          minidsp = inputs.minidsp.packages.${prev.system}.default;
          devenv = inputs.devenv.packages.${prev.system}.devenv;
          pkgsUnstable = nixpkgsUnstable.packages.${prev.system};
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
            modules = [
              hyprland.homeManagerModules.default
              ./nixpkgs/home-manager/beast.nix
            ];
          };

          "mrene@Mathieus-MBP" = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              system = "aarch64-darwin";
              config = pkgsConfig;
              overlays = packageOverlays;
            };
            modules = [ ./nixpkgs/home-manager/mac.nix ];
          };

          minimal = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              system = "x86_64-linux";
              config = pkgsConfig;
              overlays = packageOverlays;
            };
            modules = [ ./nixpkgs/home-manager/minimal.nix ];
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
              {
                home-manager.sharedModules = [
                  # XXX: Hack
                  hyprland.homeManagerModules.default
                ];
              }              
              vscode-server.nixosModule
              hyprland.nixosModules.default
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

          # sudo nixos-rebuild switch --flake .#beast
          beast = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            pkgs = import nixpkgs {
              system = "x86_64-linux";
              config = pkgsConfig;
              overlays = packageOverlays;
            };
            specialArgs = { common = self.common; inherit inputs; };
            modules = [
              ./nixpkgs/nixos/beast/hardware-configuration.nix
              ./nixpkgs/nixos/beast/configuration.nix
              hyprland.nixosModules.default
              home-manager.nixosModules.home-manager
              (homeManagerConfig ./nixpkgs/home-manager/beast.nix)
              {
                home-manager.sharedModules = [
                  # XXX: Hack
                  hyprland.homeManagerModules.default
                ];
              }
              vscode-server.nixosModule
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
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAeSvwegmfet4Rw8OBFEVUfx+5WmVcYR4/n20QSh4tAs mrene@beast"
          ];

          sudoSshKeys = [
            "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBMpIqFppmJu+oXgUA9t+KK7xY07FAy1ZpMQ2xe03fhnaufg8UAT35cTMvf5KpCDRiCRsdv37tXpmfmgV27eiFWA= Remote-sudo@secretive.Mathieu’s-MacBook-Pro.local"
          ];
        };
      }
    );
}
