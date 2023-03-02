{ config, pkgs, libs, inputs, ... }:

{
  imports = [
    ./minimal.nix
    ./ssh.nix
    ./jira
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
    kubectl-view-allocations
    # TODO : Move to work-specific env
    (google-cloud-sdk.withExtraComponents (with google-cloud-sdk.components; [ gke-gcloud-auth-plugin ]))

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

    # Nix LSPs
    rnix-lsp
    inputs.nil.packages.${system}.default
    inputs.rtx.packages.${system}.default
    nixpkgs-fmt
    nurl
    jsonnet-language-server
    buf-language-server

    # markdown lsp
    (marksman.overrideAttrs (old: {
      src = pkgs.fetchFromGitHub {
        owner = "artempyanykh";
        repo = "marksman";
        rev = "53a0c9794d738b47cde814a1700665af6d433408";
        sha256 = "1mg9x7g8y1r15avfzz42sr6431h9h2pp5zl53zwbvhzz1834yhs6";
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
    update-nix-fetchgit

    # Copilot requirement
    nodejs-16_x

    nix-output-monitor
    nix-init
  ] ++ lib.optionals stdenv.isDarwin [
    coreutils # provides `dd` with --status=progress
    wifi-password
  ] ++ lib.optionals stdenv.isLinux [
    iputils # provides `ping`, `ifconfig`, ...

    libuuid # `uuidgen` (already pre-installed on mac)
  ];
}
