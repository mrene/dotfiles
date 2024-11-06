{
  lib,
  stdenv,
  system,
  vscode-extensions,
  pkgs,
  inputs,
}:
pkgs.vscode-with-extensions.override {
  vscodeExtensions =
    # Prefer extensions that are in nixpkgs, fallback to the marketplace source
    (with (inputs.nix-vscode-extensions.extensions.${system}.forVSCodeVersion "1.95.0-20241022").vscode-marketplace; [
      donjayamanne.python-environment-manager
      gaborv.flatbuffers
      jeff-hykin.better-cpp-syntax
      malmaud.tmux
      ms-python.isort
      ms-toolsai.jupyter-keymap
      ms-vscode-remote.remote-containers
      ms-vscode.cpptools-themes
      ms-vscode.remote-explorer
      tcwalther.cython
      grafana.vscode-jsonnet
      esphome.esphome-vscode
      github.copilot
      github.copilot-chat
      vitest.explorer
    ])
    ++ (with vscode-extensions;
      [
        catppuccin.catppuccin-vsc
        vscodevim.vim

        bbenoist.nix # Nix syntax

        ms-vscode-remote.remote-ssh

        rust-lang.rust-analyzer
        matangover.mypy
        jebbs.plantuml

        # Jupyter notebook things
        ms-toolsai.jupyter
        ms-toolsai.vscode-jupyter-slideshow
        ms-toolsai.vscode-jupyter-cell-tags

        zxh404.vscode-proto3 # Protobuf
        xadillax.viml # Vim language server
        twxs.cmake

        # Languages
        golang.go
        tamasfe.even-better-toml
        ms-python.vscode-pylance

        # Nix
        brettm12345.nixfmt-vscode
        b4dm4n.vscode-nixpkgs-fmt

        skyapps.fish-vscode
        redhat.vscode-yaml
        ms-vscode.makefile-tools
        ms-vscode.cmake-tools
        mechatroner.rainbow-csv
        jnoortheen.nix-ide
        github.vscode-pull-request-github
        esbenp.prettier-vscode
        mkhl.direnv
        llvm-vs-code-extensions.vscode-clangd

        hashicorp.terraform
        hashicorp.hcl
      ]
      ++ lib.optionals (! (stdenv.isAarch64 && stdenv.isLinux)) [
        ms-vscode.cpptools
        ms-python.python
        ms-vsliveshare.vsliveshare
        ms-azuretools.vscode-docker
      ]);
}
