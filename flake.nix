{
  inputs = {
    # Package channels
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Frozen nixpkgs stable for systems that don't get updated so often (raspberry pis)
    nixpkgs-frozen.url = "github:NixOS/nixpkgs/nixos-22.11";

    # Nix tools
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland/main";

    # Generate vm images and initial boot media
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    flake-utils.url = "github:numtide/flake-utils";
    deploy-rs.url = "github:serokell/deploy-rs";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Packages sources from other flakes
    minidsp.url = "github:mrene/minidsp-rs";
    # Nix LSP
    nil.url = "github:oxalica/nil";
    # NixOS fix so that vscode-server can run correctly
    vscode-server.url = "github:msteen/nixos-vscode-server";
    # Tool to scaffold new packages automatically
    nix-init.url = "github:nix-community/nix-init";

    rtx.url = "github:mrene/rtx/fix-darwin-build";

    humanfirst-dots = {
      url = "git+ssh://git@github.com/zia-ai/shared-dotfiles";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    bedrpc = {
      url = "/home/mrene/dev/bedrpc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # the @ operator binds the left side attribute set to the right side
  # `inputs` can still be referenced, but `darwin` is bound to `inputs.darwin`, etc.
  outputs = inputs @ { self, darwin, nixpkgs, nixpkgs-frozen, home-manager, vscode-server, nixos-generators, hyprland, flake-utils, humanfirst-dots, nixos-hardware, ... }:
    let
      config = {
        allowUnfree = true;
      };

      # Add custom packages to nixpkgs
      packageOverlay = (final: prev: ((import ./packages) prev));
      overlays = [
        # Locally defined pacakges
        packageOverlay
        (import ./overlays/vscode-with-extensions.nix)
        (import ./overlays/openrgb)
        (final: prev: {
          bedrpc = prev.callPackage "${inputs.bedrpc}/package.nix" { };
        })
      ];

      overlayModule = {...}: {
        nixpkgs.overlays = overlays;
        nixpkgs.config.allowUnfree = true;
      };

      rpiOverlays = [(final: super: {
        # Allow missing modules because the master module list is based on strings and the rpi kernel
        # is missing some
        # https://github.com/NixOS/nixpkgs/issues/154163
        makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
      })];
    in
    flake-utils.lib.eachDefaultSystem
      (system: (
        let
          pkgs = import nixpkgs { inherit system overlays config; };
        in
        {

          home = {
            beast = home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [ ./home-manager/beast.nix ];
              extraSpecialArgs = { inherit inputs; };
            };

            mac = home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [ ./home-manager/mac.nix ];
              extraSpecialArgs = { inherit inputs; };
            };

            # nix build .#home.x86-64_linux.minimal.activationPackage
            minimal = home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [ ./home-manager/minimal.nix ];
              extraSpecialArgs = { inherit inputs; };
            };
          };

          packages = (import ./packages) pkgs;

          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              nixos-generators.packages.${system}.nixos-generate
              nixos-install-tools
            ];
          };
        }
      )) // {

      homeConfigurations = {
        "mrene@beast" = self.home.x86_64-linux.beast;
        "mrene@Mathieus-MBP" = self.home.aarch64-darwin.mac;
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
            ./darwin/mbp2021/configuration.nix
            home-manager.darwinModules.home-manager
            { home-manager.extraSpecialArgs = { inherit inputs; }; }
          ];
          inputs = { inherit inputs darwin; };
        };
      };

      nixosConfigurations = {

        # sudo nixos-rebuild switch --flake .#beast
        beast = inputs.nixpkgs.lib.nixosSystem {
          specialArgs = { inherit (self) common; inherit inputs; };
          modules = [ ./nixos/beast/configuration.nix overlayModule ];
        };

        # sudo nixos-rebuild switch --flake .#utm
        utm = inputs.nixpkgs.lib.nixosSystem {
          specialArgs = { inherit (self) common; inherit inputs; };
          modules = [ ./nixos/utm/configuration.nix overlayModule ];
        };


        nascontainer = inputs.nixpkgs.lib.nixosSystem {
          specialArgs = { inherit (self) common; inherit inputs; };
          modules = [ ./nixos/nas/configuration.nix overlayModule ];
        };

        # Raspberry Pis
        bedpi =
          # Patch nixpkgs to add a cmake flag to compiler-rt - it could probably be done with an overlay but I can't figure out the
          # import path since it's callPackaged at a bunch of places
          let
            vanillaPkgs = (import nixpkgs { system = "x86_64-linux"; });
            armv6-llvm-patch = vanillaPkgs.fetchpatch {
              url = "https://github.com/NixOS/nixpkgs/pull/205176.patch";
              hash = "sha256-QGviAj8m86GFMRneFlsX69xFhRHlI+0PlQezLFwg90Q=";
            };
            rpi1nixpkgs = vanillaPkgs.applyPatches {
              name = "armv6-build";
              src = nixpkgs;
              patches = [ armv6-llvm-patch  ];
            };
          in
          inputs.nixpkgs.lib.nixosSystem {
            pkgs = import rpi1nixpkgs {
              inherit config;
              overlays = overlays ++ rpiOverlays;
              system = "x86_64-linux";
              crossSystem = {
                system = "armv6l-linux";
                # https://discourse.nixos.org/t/building-libcamera-for-raspberry-pi/26133/9
                gcc = {
                  arch = "armv6k";
                  fpu = "vfp";
                };
              };
            };
            specialArgs = { inherit (self) common; inherit inputs; };
            modules = [
              ./nixos/bedpi/configuration.nix
              "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-raspberrypi.nix"
            ];
          };


        tvpi = inputs.nixpkgs-frozen.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { common = self.common; inherit inputs; };
          modules = [
            nixos-hardware.outputs.nixosModules.raspberry-pi-4
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            ./nixos/tvpi/configuration.nix
            ({...}: {
              nixpkgs.config.allowUnfree = true;
              nixpkgs.overlays = overlays ++ rpiOverlays;
            })
          ];
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
