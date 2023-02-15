{ config, pkgs, libs, inputs, ... }:
{
  imports = [
    ./minimal.nix
    ./jira.nix
  ];

  # https://github.com/nix-community/nix-direnv#via-home-manager
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  home.packages = with pkgs; [

    # Nix tools
    manix # nix cli search tool
    comma # run any command with `, command`
    nix-index # and nix-locate, search within prebuilt packages filenames
    cachix # Alternative prebuilt cache for nix

    # Ops tools
    sops
    kubectx
    kubectl
    k9s

    graphviz
    curlie

    youtube-dl
    speedtest-cli

    # JS
    yarn

    go
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

    pkgsUnstable.jira-cli-go

    # Nix LSPs
    rnix-lsp
    inputs.nil.packages.${system}.default
    nixpkgs-fmt
    pkgsUnstable.nurl
    pkgsUnstable.jsonnet-language-server
    buf-language-server

    # markdown lsp
    (marksman.overrideAttrs(old: {
      src = pkgs.fetchFromGitHub {
        owner = "artempyanykh";
        repo = "marksman";
        rev = "670524e9dff15db45ae2c8aa8c7586917ead4f1f";
        sha256 = "045537j859wqnpfxp0bm3z9wwx8bqa8485lb2l7yr90fglcz7w8r";
      };
    }))
    # Rust
    rust-analyzer
    cargo-edit

    # Microsoft's python LSP
    nodePackages.pyright
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted

    # github cli
    gitAndTools.gh

    #(update-nix-fetchgit.overrideAttrs(old: {
      #src = fetchFromGitHub {
        #owner = "expipiplus1";
        #repo = "update-nix-fetchgit";
        #rev = "78133d1b61c05cfe0a251defb3bcd4729fab9513";
        #sha256 = _;
      #};
    #}))
    pkgsUnstable.update-nix-fetchgit

    # Copilot requirement
    nodejs-16_x

  ] ++ lib.optionals stdenv.isDarwin [
    coreutils # provides `dd` with --status=progress
    wifi-password
  ] ++ lib.optionals stdenv.isLinux [
    iputils # provides `ping`, `ifconfig`, ...

    libuuid # `uuidgen` (already pre-installed on mac)
  ];
}
