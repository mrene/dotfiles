{ config, pkgs, pkgsUnstable, libs, ... }:
{

  # https://github.com/nix-community/nix-direnv#via-home-manager
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  home.packages = with pkgs; [
    # Shell
    starship

    tmux
    wget
    bat
    bottom
    fzf
    rename
    neofetch # fancy system + hardware info
    tealdeer # fast tldr
    zoxide # habitual `cd`
    any-nix-shell # allows using fish for `nix shell`
    igrep # interactive grep

    # Nix tools
    nvd # nix package diff tool
    manix # nix cli search tool
    nix-index

    # Requires a patched font
    # https://github.com/ryanoasis/nerd-fonts/blob/master/readme.md#patched-fonts
    lsd
    tree
    # better du alternative
    du-dust
    ripgrep
    graphviz
    # git-crypt

    # Ops tools
    sops
    kubectx
    kubectl
    k9s

    # httpstat
    curlie

    # https://github.com/sindresorhus/fkill
    # nodePackages.fkill-cli

    youtube-dl
    speedtest-cli

    yarn
    # python310
    # python310Packages.grpcio

    jq
    jless
    go
    # cloc
    docker
    tailscale

    # ran # quick local webserver (`-r [folder]`)

    # compression
    zip
    pigz # parallel gzip
    lz4

    # docker-compose
    # Nix VSC
    rnix-lsp
    nil
    nixpkgs-fmt

    # Rust 
    rust-analyzer


    comma
    cachix

    # needed for headless chrome
    # chromium

    git
    # github cli
    gitAndTools.gh

  ] ++ lib.optionals stdenv.isDarwin [
    coreutils # provides `dd` with --status=progress
    wifi-password
  ] ++ lib.optionals stdenv.isLinux [
    iputils # provides `ping`, `ifconfig`, ...

    libuuid # `uuidgen` (already pre-installed on mac)
  ];

  programs.tmux = {
    enable = true;
    clock24 = true;
  };

  programs.dircolors = {
    enable = true;
  };



}
