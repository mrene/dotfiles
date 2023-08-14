{
  inputs = {
    # Package channels
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Wait for https://nixpk.gs/pr-tracker.html?pr=248278
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    # Frozen nixpkgs stable for systems that don't get updated so often (raspberry pis)
    nixpkgs-frozen.url = "github:NixOS/nixpkgs/e3652e0735fbec227f342712f180f4f21f0594f2";

    home-manager = {
      # Tenative fix for nix 2.17 issue
      # https://github.com/nix-community/home-manager/issues/4298
      url = "github:nix-community/home-manager/master";
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
  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./overlays
        ./nixos
        ./darwin
        ./home-manager
      ];
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      perSystem = { config, system, ... }:
        let
          overlays = [ ]; #config.flake.overlays.default;
          pkgs = import inputs.nixpkgs {
            inherit system overlays;
            config = { allowUnfree = true; };
          };
        in
        {
          packages = ((import ./packages) pkgs);

          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              nixos-generators.packages.${system}.nixos-generate
              nixos-install-tools
            ];
          };
        };
      flake.common = {
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
