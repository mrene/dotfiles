{
  inputs = {
    #nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:NixOS/nixpkgs/staging-next";

    nixpkgs-pr-openthread.url = "github:mrene/nixpkgs?ref=openthread-border-router";

    nixpkgs-unfree = {
      url = "github:numtide/nixpkgs-unfree";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mrene-nur = {
      url = "github:mrene/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixos-generators.url = "github:nix-community/nixos-generators"; # Generate vm images and initial boot media
    # Raspberry Pi 4 modules
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    attic = {
      url = "github:zhaofengli/attic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    minidsp = {
      url = "github:mrene/minidsp-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fzf-nix = {
      url = "github:mrene/fzf-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixd = {
      url = "github:nix-community/nixd";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat = {
      url = "github:inclyc/flake-compat";
      flake = false;
    }; # Required for nixd
    vscode-server = {
      url = "github:msteen/nixos-vscode-server"; # NixOS fix so that vscode-server can run correctly
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-init = {
      url = "github:nix-community/nix-init"; # Tool to scaffold new packages automatically
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Pre-indexed nix-index db
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
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-update = {
      url = "github:Mic92/nix-update";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions = { 
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
