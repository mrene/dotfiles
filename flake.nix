# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{

  outputs = inputs: import ./outputs.nix inputs;

  nixConfig = {
    extra-substituters = [ "https://nixos-raspberrypi.cachix.org" ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  inputs = {
    attic = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:zhaofengli/attic";
    };
    clan-core = {
      inputs = {
        flake-parts.follows = "flake-parts";
        nix-darwin.follows = "darwin";
        nixpkgs.follows = "nixpkgs";
      };
      url = "https://git.clan.lol/clan/clan-core/archive/main.tar.gz";
    };
    darwin = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    };
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    devshell = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:numtide/devshell";
    };
    flake-aspects.url = "github:vic/flake-aspects";
    flake-compat = {
      flake = false;
      url = "https://git.lix.systems/lix-project/flake-compat/archive/main.tar.gz";
    };
    flake-file.url = "github:vic/flake-file";
    flake-parts.url = "github:hercules-ci/flake-parts";
    fzf-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:mrene/fzf-nix";
    };
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager/release-25.11";
    };
    humanfirst-dots = {
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
      url = "git+ssh://git@github.com/zia-ai/shared-dotfiles";
    };
    import-tree.url = "github:vic/import-tree";
    llm-agents = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:numtide/llm-agents.nix";
    };
    mcp-hub = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:ravitemer/mcp-hub";
    };
    mcphub-nvim = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:ravitemer/mcphub.nvim";
    };
    minidsp.url = "github:mrene/minidsp-rs";
    mrene-nur = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:mrene/nur-packages";
    };
    nix-index-database = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Mic92/nix-index-database";
    };
    nix-update = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Mic92/nix-update";
    };
    nix-vscode-extensions = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/nix-vscode-extensions";
    };
    nixos-lima = {
      inputs = {
        disko.follows = "clan-core/disko";
        nixpkgs.follows = "nixpkgs";
      };
      url = "github:ciderale/nixos-lima";
    };
    nixos-raspberrypi = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nvmd/nixos-raspberrypi/main";
    };
    nixos-raspberrypi-nofollows.url = "github:nvmd/nixos-raspberrypi/main";
    nixos-wsl = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/NixOS-WSL";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-pr-openthread.url = "github:mrene/nixpkgs?ref=openthread-border-router";
    sops-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Mic92/sops-nix";
    };
    vscode-server = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:msteen/nixos-vscode-server";
    };
  };

}
