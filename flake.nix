{
  inputs = {
    # Package channels
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Nix tools
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    hyprland.url = "github:hyprwm/Hyprland/main";

    # Generate vm images and initial boot media
    nixos-generators.url = "github:nix-community/nixos-generators";

    flake-utils.url = "github:numtide/flake-utils";
    deploy-rs.url = "github:serokell/deploy-rs";
    darwin.url = "github:lnl7/nix-darwin/master";

    # Packages sources from other flakes
    minidsp.url = "github:mrene/minidsp-rs";
    # Nix LSP
    nil.url = "github:oxalica/nil";
    # NixOS fix so that vscode-server can run correctly
    vscode-server.url = "github:msteen/nixos-vscode-server";
    # Tool to scaffold new packages automatically
    nix-init.url = "github:nix-community/nix-init";
  };

  # the @ operator binds the left side attribute set to the right side
  # `inputs` can still be referenced, but `darwin` is bound to `inputs.darwin`, etc.
  outputs = inputs @ { self, darwin, nixpkgs, home-manager, vscode-server, nixos-generators, hyprland, flake-utils, ... }:
      let
        config = {
          allowUnfree = true;
        };

        # Add custom packages to nixpkgs
        packageOverlay = final: prev: {
          kubectl-view-allocations = prev.callPackage ./packages/kubectl-view-allocations { };
          pathfind = prev.callPackage ./packages/pathfind { };
          rgb-auto-toggle = prev.callPackage ./packages/rgb-auto-toggle { };
        };

        overlays = [
          packageOverlay
          (import ./overlays/vscode-with-extensions.nix)
          (import ./overlays/openrgb)
        ];

    in

    flake-utils.lib.eachDefaultSystem
      (system: (
        let
          pkgs = import nixpkgs { inherit system overlays config; };
        in
        {

        home = {
          "mrene@beast" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [ ./home-manager/beast.nix ];
            extraSpecialArgs = { inherit inputs; };
          };

          "mrene@Mathieus-MBP" = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              inherit system overlays config;
            };
            modules = [ ./home-manager/mac.nix ];
            extraSpecialArgs = { inherit inputs; };
          };

          minimal = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [ ./home-manager/minimal.nix ];
            extraSpecialArgs = { inherit inputs; };
          };
        };

          packages = {
            pathfind = pkgs.callPackage ./packages/pathfind { };
            rgb-auto-toggle = pkgs.callPackage ./packages/rgb-auto-toggle { };
            kubectl-view-allocations = pkgs.callPackage ./packages/kubectl-view-allocations { };
          };
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              nixos-generators.packages.${system}.nixos-generate
              nixos-install-tools
            ];
          };
        }
        )) // {

        homeConfigurations = {
          "mrene@beast" = self.home.x86_64-linux."mrene@beast";
          "mrene@Mathieus-MBP" = self.home.aarch64-darwin."mrene@Mathieus-MBP";
        };

        darwinConfigurations = {
          # nix build .#darwinConfigurations.mbp2021.system
          # ./result/sw/bin/darwin-rebuild switch --flake .
          Mathieus-MBP = darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            pkgs = import nixpkgs {
              inherit config overlays;
              system = "aarch64-darwin";
            };
            modules = [
              #home-manager.darwinModules.home-manager
              ./darwin/mbp2021/configuration.nix
            ];
            inputs = { inherit inputs darwin; };
          };
        };

        nixosConfigurations = {

          # sudo nixos-rebuild switch --flake .#utm
          utm = inputs.nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            pkgs = import nixpkgs {
              inherit config overlays;
              system = "aarch64-linux";
            };
            specialArgs = { common = self.common; inherit inputs; };
            modules = [ ./nixos/utm/configuration.nix ];
          };

          # sudo nixos-rebuild switch --flake .#qemu
          qemu = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            pkgs = import nixpkgs {
              inherit config overlays;
              system = "x86_64-linux";
            };
            specialArgs = { common = self.common; inherit inputs; };
            modules = [ ./nixos/qemu/configuration.nix ];
          };

          # sudo nixos-rebuild switch --flake .#beast
          beast = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            pkgs = import nixpkgs {
              inherit config overlays;
              system = "x86_64-linux";
            };
            specialArgs = { common = self.common; inherit inputs; };
            modules = [ ./nixos/beast/configuration.nix ];
          };
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
      };
}
