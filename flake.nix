{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-pr-openthread.url = "github:mrene/nixpkgs?ref=openthread-border-router";

    nixpkgs-unfree = {
      url = "github:numtide/nixpkgs-unfree";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mrene-nur = {
      url = "github:mrene/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixos-generators.url = "github:nix-community/nixos-generators"; # Generate vm images and initial boot media
    # Raspberry Pi 4 modules
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi/main";
      # https://github.com/nvmd/nixos-raspberrypi/issues/90
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Direct reference to CI-built nixos-raspberrypi to avoid rebuilding the kernel
    nixos-raspberrypi-nofollows = {
      url = "github:nvmd/nixos-raspberrypi/main";
    };
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
    };
    fzf-nix = {
      url = "github:mrene/fzf-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixd = {
      url = "github:nix-community/nixd";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Use flake-compat from Lix since it can be configured to skip copying things to the store
    flake-compat = {
      url = "https://git.lix.systems/lix-project/flake-compat/archive/main.tar.gz";
      flake = false;
    };

    vscode-server = {
      url = "github:msteen/nixos-vscode-server"; # NixOS fix so that vscode-server can run correctly
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
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix2container = {
      url = "github:nlewo/nix2container";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mcphub-nvim = {
      url = "github:ravitemer/mcphub.nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mcp-hub = {
      url = "github:ravitemer/mcp-hub";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";  

    nixos-lima = {
      url = "github:ciderale/nixos-lima";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./packages.nix
        ./overlays
        ./nixos
        ./darwin
        ./home-manager
        # ./vim
        ./devshell.nix
        ./common.nix
        ./neovim
        ({ config, ... }: 
        let
            allTopLevels = (inputs.nixpkgs.lib.mapAttrsToList (k: v: v.config.system.build.toplevel.drvPath) config.flake.nixosConfigurations);
        in  
        {
          flake.nixosConfigurations' = builtins.parallel 
            allTopLevels
            (config.flake.nixosConfigurations.beast.pkgs.symlinkJoin { name = "all"; paths = allTopLevels; });
        })
      ];
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
    };
}
