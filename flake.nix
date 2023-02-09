{
  inputs = {
    # Package channels
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgsUnstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Nix tools
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
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

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
          packages = {
            pathfind = pkgs.callPackage ./nixpkgs/packages/pathfind { };
          };
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
          permittedInsecurePackages = [ ];
          allowUnfree = true;
        };

        # Overlay adding flake inputs inside `pkgs`
        packageOverlay = final: prev: {
          minidsp = inputs.minidsp.packages.${prev.system}.default;
          devenv = inputs.devenv.packages.${prev.system}.devenv;
          pkgsUnstable = import nixpkgsUnstable {
            inherit (prev) system;
            config = pkgsConfig;
            overlays = packageOverlays;
          };
          pathfind = prev.callPackage ./nixpkgs/packages/pathfind { };
        };

        packageOverlays = [
          packageOverlay
          (import ./nixpkgs/overlays/vscode-with-extensions.nix)
        ];
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
            extraSpecialArgs = { inherit inputs; };
          };

          "mrene@Mathieus-MBP" = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              system = "aarch64-darwin";
              config = pkgsConfig;
              overlays = packageOverlays;
            };
            modules = [ ./nixpkgs/home-manager/mac.nix ];
            extraSpecialArgs = { inherit inputs; };
          };

          minimal = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              system = "x86_64-linux";
              config = pkgsConfig;
              overlays = packageOverlays;
            };
            modules = [ ./nixpkgs/home-manager/minimal.nix ];
            extraSpecialArgs = { inherit inputs; };
          };
        };

        darwinConfigurations = {
          # nix build .#darwinConfigurations.mbp2021.system
          # ./result/sw/bin/darwin-rebuild switch --flake .
          Mathieus-MBP = darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            pkgs = import nixpkgs {
              system = "aarch64-darwin";
              config = pkgsConfig;
              overlays = packageOverlays;
            };
            modules = [
              #home-manager.darwinModules.home-manager
              ./nixpkgs/darwin/mbp2021/configuration.nix
            ];
            inputs = { inherit inputs darwin; };
          };
        };

        nixosConfigurations = {
          # sudo nixos-rebuild switch --flake .#homepi
          # homepi = inputs.nixpkgs.lib.nixosSystem {
          #   system = "aarch64-linux";
          #   specialArgs = { common = self.common; inherit inputs; };
          #   modules = [ ];
          # };

          # sudo nixos-rebuild switch --flake .#utm
          utm = inputs.nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            pkgs = import nixpkgs {
              system = "aarch64-linux";
              config = pkgsConfig;
              overlays = packageOverlays;
            };
            specialArgs = { common = self.common; inherit inputs; };
            modules = [ ./nixpkgs/nixos/utm/configuration.nix ];
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
            modules = [ ./nixpkgs/nixos/qemu/configuration.nix ];
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
            modules = [ ./nixpkgs/nixos/beast/configuration.nix ];
          };
        };

        images = {
          # nix build .#images.homepi
          homepi = self.nixosConfigurations.homepi.config.system.build.sdImage;
        };

        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config = pkgsConfig;
          overlays = packageOverlays;
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
