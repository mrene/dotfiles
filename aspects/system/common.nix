{ lib, inputs, ... }:
{
  # Declare inputs used by this aspect for flake-file tracking
  flake-file.inputs = {
    fzf-nix = {
      url = "github:mrene/fzf-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mrene-nur = {
      url = "github:mrene/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    humanfirst-dots = {
      url = "git+ssh://git@github.com/zia-ai/shared-dotfiles";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  flake.aspects.system-common.homeManager =
    { pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
    in
    {
      imports = [
        inputs.humanfirst-dots.homeManagerModule
        inputs.nix-index-database.homeModules.nix-index
        inputs.self.homeManagerModules.neovim
      ];

      humanfirst.enable = true;
      humanfirst.identity.email = "mathieu@humanfirst.ai";

      # https://github.com/nix-community/nix-direnv#via-home-manager
      programs.direnv.enable = true;
      programs.direnv.nix-direnv.enable = true;

      home.packages =
        with pkgs;
        [
          inputs.mrene-nur.packages.${system}.hctl
          # Nix tools
          comma # run any command with `, command`
          #nix-index # and nix-locate, search within prebuilt packages filenames
          cachix # Alternative prebuilt cache for nix

          # Ops tools
          sops
          kubectx
          kubectl
          k9s
          #kubectl-view-allocations
          # TODO : Move to work-specific env
          (google-cloud-sdk.withExtraComponents (
            with google-cloud-sdk.components; [ gke-gcloud-auth-plugin ]
          ))

          graphviz
          curlie

          #yt-dlp
          speedtest-cli

          # JS
          yarn

          #go
          gopls # LSP
          delve
          go-tools

          lldb # For lldb-vscode in nvim-dap

          # TODO: Should be in per-machine setup instead of common
          tailscale
          docker

          # compression
          zip
          pigz # parallel gzip
          lz4

          # Nix LSPs
          nixd
          nixpkgs-fmt
          nurl
          jsonnet-language-server
          buf
          mise

          # markdown lsp
          #extraLuaConfig marksman
          # Rust
          rust-analyzer
          cargo-edit

          # Microsoft's python LSP
          pyright
          nodePackages.typescript-language-server
          nodePackages.vscode-langservers-extracted

          # github cli
          gh

          #(update-nix-fetchgit.overrideAttrs(old: {
          #src = fetchFromGitHub {
          #owner = "expipiplus1";
          #repo = "update-nix-fetchgit";
          #rev = "78133d1b61c05cfe0a251defb3bcd4729fab9513";
          #sha256 = _;
          #};
          #}))
          update-nix-fetchgit

          # Copilot requirement
          nodejs

          nix-output-monitor
          nix-init
          alejandra
          deadnix
          nixfmt
          statix
          entr
          inputs.fzf-nix.packages.${system}.fzf-nix

          # TUI file browser
          yazi
          aichat
          zellij
        ]
        ++ lib.optionals stdenv.isDarwin [
          coreutils # provides `dd` with --status=progress
        ]
        ++ lib.optionals stdenv.isLinux [
          iputils # provides `ping`, `ifconfig`, ...
          # aider-chat
          libuuid # `uuidgen` (already pre-installed on mac)
        ];
    };
}
