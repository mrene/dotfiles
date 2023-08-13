{
  inputs = {
    # Package channels
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Wait for https://nixpk.gs/pr-tracker.html?pr=248278
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    # Frozen nixpkgs stable for systems that don't get updated so often (raspberry pis)
    nixpkgs-frozen.url = "github:NixOS/nixpkgs/e3652e0735fbec227f342712f180f4f21f0594f2";

    # Nix tools
    home-manager = {
      # Tenative fix for nix 2.17 issue
      # https://github.com/nix-community/home-manager/issues/4298
      url = "github:nix-community/home-manager/fix/4298";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Generate vm images and initial boot media
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    flake-utils.url = "github:numtide/flake-utils";
    deploy-rs.url = "github:serokell/deploy-rs";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Packages sources from other flakes
    minidsp = {
      url = "github:mrene/minidsp-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Nix LSP
    nil.url = "github:oxalica/nil";
    # NixOS fix so that vscode-server can run correctly
    vscode-server.url = "github:msteen/nixos-vscode-server";
    # Tool to scaffold new packages automatically
    nix-init.url = "github:nix-community/nix-init";

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    humanfirst-dots = {
      url = "git+ssh://git@github.com/zia-ai/shared-dotfiles";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    bedrpc = {
      url = "git+ssh://git@github.com/mrene/bedrpc";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-compat = {
      url = "github:inclyc/flake-compat";
      flake = false;
    };

    nixd = { 
      url = "github:nix-community/nixd";
    };

    nh = {
      url = "github:mrene/nh/fix-system-error-2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # the @ operator binds the left side attribute set to the right side
  # `inputs` can still be referenced, but `darwin` is bound to `inputs.darwin`, etc.
  outputs = inputs @ { self, darwin, nixpkgs, nixpkgs-frozen, home-manager, nixos-generators, flake-utils, nixos-hardware, ... }:
    let
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "nodejs-16.20.0"
        ];
      };

      # Add custom packages to nixpkgs
      packageOverlay = (final: prev: ((import ./packages) prev));
      overlays = [
        # Locally defined pacakges
        packageOverlay
        (import ./overlays/vscode-with-extensions.nix)
        (import ./overlays/openrgb)
      ];

      overlayModule = { ... }: {
        nixpkgs.overlays = overlays;
        nixpkgs.config.allowUnfree = true;
      };

      rpiOverlays = [
        (final: super: {
          # Allow missing modules because the master module list is based on strings and the rpi kernel
          # is missing some
          # https://github.com/NixOS/nixpkgs/issues/154163
          makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
        })
      ];
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

            nas = home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [ ./home-manager/nas.nix ];
              extraSpecialArgs = { inherit inputs; };
            };

            # nix build .#home.x86-64_linux.minimal.activationPackage
            minimal = home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [ ./home-manager/minimal.nix ];
              extraSpecialArgs = { inherit inputs; };
            };
          };

          packages = ((import ./packages) pkgs) // {
            buildClosure =
              let
                deps = builtins.split "\n" (builtins.readFile ./rpi-cross-deps.txt);
                rootPaths = builtins.filter (x: x != "") deps;
              in
              pkgs.closureInfo { rootPaths = rootPaths; };
          };

          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              nixos-generators.packages.${system}.nixos-generate
              nixos-install-tools
            ];
          };

          devShells.rpi1cross = pkgs.mkShell {
            inputsFrom = [ self.nixosConfigurations.bedpi.config.system.build.toplevel ];
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
          specialArgs = { inherit inputs; };
        };
      };

      nixosConfigurations =
        let
          rpi1pkgs = import nixpkgs-frozen {
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
        in
        {
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

          nas = inputs.nixpkgs.lib.nixosSystem {
            specialArgs = { inherit (self) common; inherit inputs; };
            modules = [ ./nixos/nas/configuration.nix overlayModule ];
          };

          # Raspberry Pis
          bedpi = inputs.nixpkgs-frozen.lib.nixosSystem {
            pkgs = rpi1pkgs;
            specialArgs = { inherit (self) common; inherit inputs; };
            modules = [
              ./nixos/rpis/bedpi/configuration.nix
              "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-raspberrypi.nix"
            ];
          };

          testpi = inputs.nixpkgs-frozen.lib.nixosSystem {
            pkgs = rpi1pkgs;
            specialArgs = { inherit (self) common; inherit inputs; };
            modules = [
              ./nixos/rpis/testpi/configuration.nix
              "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-raspberrypi.nix"
            ];
          };

          tvpi = inputs.nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            specialArgs = { common = self.common; inherit inputs; };
            modules = [
              nixos-hardware.outputs.nixosModules.raspberry-pi-4
              "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
              ./nixos/rpis/tvpi/configuration.nix
              ({ ... }: {
                nixpkgs.config.allowUnfree = true;
                nixpkgs.overlays = overlays ++ rpiOverlays;
              })
            ];
          };
        };


        nasbuild = self.nixosConfigurations.nas.config.system.build.toplevel;

        # CI top level targets
        ciTargets = inputs.nixpkgs.lib.genAttrs [ "beast" "nas" "utm" "tvpi" "bedpi" ] (name : self.nixosConfigurations.${name}.config.system.build.toplevel);

      common = {
        sshKeys = [
          "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBMDK9LCwU62BIcyn73TcaQlMqr12GgYnHYcw5dbDDNmYnpp2n/jfDQ5hEkXd945dcngW6yb7cmgsa8Sx9T1Uuo4= secretive@mbp2021"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAeSvwegmfet4Rw8OBFEVUfx+5WmVcYR4/n20QSh4tAs mrene@beast"
        ];

        builderKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGYXed3Lzz4fWZmjt7VHvWDldk1VNlcSDokM7ZcguTFh root@beast"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHeCYLyIA2TgH8tE5i8pyCV2HvU/iepBx/ch6gh8IwbC nas-builder"
        ];

        sudoSshKeys = [
          "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBMpIqFppmJu+oXgUA9t+KK7xY07FAy1ZpMQ2xe03fhnaufg8UAT35cTMvf5KpCDRiCRsdv37tXpmfmgV27eiFWA= Remote-sudo@secretive.Mathieu’s-MacBook-Pro.local"
        ];
      };
    };
}
