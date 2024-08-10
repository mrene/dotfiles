{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs-unfree = {
      url = "github:numtide/nixpkgs-unfree";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-frozen.url = "github:NixOS/nixpkgs/8ecc900b2f695d74dea35a92f8a9f9b32c8ea33d"; # Frozen nixpkgs stable for systems that don't get updated so often (raspberry pis)
    nixpkgs-before-electron-eol.url = "github:NixOS/nixpkgs/8de5bd2ac7c9a1c77a38e8951daa889b6052697f";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mrene-nur = {
      url = "github:mrene/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators.url = "github:nix-community/nixos-generators"; # Generate vm images and initial boot media
    nixos-hardware.url = "github:NixOS/nixos-hardware"; # Raspberry Pi 4 modules
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    attic.url = "github:zhaofengli/attic";
    minidsp = {
      url = "github:mrene/minidsp-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fzf-nix = {
      url = "github:mrene/fzf-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nil.url = "github:oxalica/nil"; # Nix LSP
    nixd = {url = "github:nix-community/nixd";};
    flake-compat = {
      url = "github:inclyc/flake-compat";
      flake = false;
    }; # Required for nixd
    vscode-server.url = "github:msteen/nixos-vscode-server"; # NixOS fix so that vscode-server can run correctly
    nix-init.url = "github:nix-community/nix-init"; # Tool to scaffold new packages automatically
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    }; # Pre-indexed nix-index db
    humanfirst-dots = {
      url = "git+ssh://git@github.com/zia-ai/shared-dotfiles";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bedrpc = {
      url = "git+ssh://git@github.com/mrene/bedrpc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nh = {
      url = "github:viperML/nh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devshell.url = "github:numtide/devshell";
    nix-update.url = "github:Mic92/nix-update";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./overlays
        ./nixos
        ./darwin
        ./home-manager
        ./vim
        ./packages.nix
        ./devshell.nix
        ./common.nix
      ];
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
    };
}
