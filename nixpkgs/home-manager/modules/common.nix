{ config, pkgs, libs, inputs, ... }:
{
  imports = [
    ./minimal.nix
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

    # TODO: Should be in per-machine setup instead of common
    tailscale
    docker

    # compression
    zip
    pigz # parallel gzip
    lz4

    # Nix LSPs
    rnix-lsp
    inputs.nil.packages.${system}.default
    nixpkgs-fmt
    pkgsUnstable.nurl
    pkgsUnstable.jsonnet-language-server
    buf-language-server
    marksman # markdown lsp

    # Rust
    rust-analyzer
    rustup
    cargo-edit

    # Microsoft's python LSP
    nodePackages.pyright
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted

    # github cli
    gitAndTools.gh

    update-nix-fetchgit

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
