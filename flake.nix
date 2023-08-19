{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unfree = { url = "github:numtide/nixpkgs-unfree"; inputs.nixpkgs.follows = "nixpkgs"; };
    nixpkgs-frozen.url = "github:NixOS/nixpkgs/e3652e0735fbec227f342712f180f4f21f0594f2"; # Frozen nixpkgs stable for systems that don't get updated so often (raspberry pis)
    home-manager = { url = "github:nix-community/home-manager/master"; inputs.nixpkgs.follows = "nixpkgs"; };
    nixos-generators.url = "github:nix-community/nixos-generators"; # Generate vm images and initial boot media
    nixos-hardware.url = "github:NixOS/nixos-hardware"; # Raspberry Pi 4 modules
    darwin = { url = "github:lnl7/nix-darwin/master"; inputs.nixpkgs.follows = "nixpkgs"; };
    minidsp = { url = "github:mrene/minidsp-rs"; inputs.nixpkgs.follows = "nixpkgs"; };
    nil.url = "github:oxalica/nil"; # Nix LSP
    nixd = { url = "github:nix-community/nixd"; };
    flake-compat = { url = "github:inclyc/flake-compat"; flake = false; }; # Required for nixd
    vscode-server.url = "github:msteen/nixos-vscode-server"; # NixOS fix so that vscode-server can run correctly
    nix-init.url = "github:nix-community/nix-init"; # Tool to scaffold new packages automatically
    nix-index-database = { url = "github:Mic92/nix-index-database"; inputs.nixpkgs.follows = "nixpkgs"; }; # Pre-indexed nix-index db
    humanfirst-dots = { url = "git+ssh://git@github.com/zia-ai/shared-dotfiles"; inputs.nixpkgs.follows = "nixpkgs"; };
    bedrpc = { url = "git+ssh://git@github.com/mrene/bedrpc"; inputs.nixpkgs.follows = "nixpkgs"; };
    nh = { url = "github:viperML/nh"; inputs.nixpkgs.follows = "nixpkgs"; };
    devshell.url = "github:numtide/devshell";
    nix-update.url = "github:Mic92/nix-update";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ config, self, ... }: {
      imports = [
        ./overlays
        ./nixos
        ./darwin
        ./home-manager
        ./packages/flake-module.nix
        ./devshell.nix
        ./common.nix
      ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
    });
}
