final: prev: (
  let

    pkgs = prev;

    # Generated from: https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/vscode/extensions/update_installed_exts.sh
    # Manually removed extensions that had a nixpkgs entry
    marketplaceExtensions = prev.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "python-environment-manager";
        publisher = "donjayamanne";
        version = "1.0.4";
        sha256 = "16lnkzw96j30lk7i39r1dkdcimmc3kcqq4ri8c77562ay765pfhk";
      }
      {
        name = "flatbuffers";
        publisher = "gaborv";
        version = "0.1.0";
        sha256 = "1jqa5824cv79w3xrln60k5i0s1l4l6qjvi9jkswy1rdd53b2csyx";
      }
      {
        name = "jsonnet";
        publisher = "heptio";
        version = "0.1.0";
        sha256 = "1m0iwk7qn3dhg3qwafm2xzyrcms421xd24ivrz138abj8f8ra203";
      }
      {
        name = "better-cpp-syntax";
        publisher = "jeff-hykin";
        version = "1.17.3";
        sha256 = "025qvvy4rgxm180sgi5l64f1kzkhy1hzspqvig8jkv340xcx5wbp";
      }
      {
        name = "tmux";
        publisher = "malmaud";
        version = "0.4.0";
        sha256 = "1zplcyih52fcw1jf73mx87wswq81566ki26n98iymxkc0mkfhrai";
      }
      {
        name = "isort";
        publisher = "ms-python";
        version = "2022.9.13271012";
        sha256 = "1iq893jx75lqx9fc3066x4qkyb3shaiqz8d3qryn8qgsf9rxwkpk";
      }
      {
        name = "jupyter-keymap";
        publisher = "ms-toolsai";
        version = "1.0.0";
        sha256 = "0wkwllghadil9hk6zamh9brhgn539yhz6dlr97bzf9szyd36dzv8";
      }
      {
        name = "remote-containers";
        publisher = "ms-vscode-remote";
        version = "0.266.1";
        sha256 = "sha256-D0nwLKGojvvRuviGRI9zo4SZmpZgee7ZpHLWjUK3LWA=";
      }
      {
        name = "cpptools-themes";
        publisher = "ms-vscode";
        version = "2.0.0";
        sha256 = "05r7hfphhlns2i7zdplzrad2224vdkgzb0dbxg40nwiyq193jq31";
      }
      {
        name = "remote-explorer";
        publisher = "ms-vscode";
        version = "0.1.2023010209";
        sha256 = "18ybd5n6ka1rmzppz9qqqq6lgi9dgr8pjgga4kahgxma91jb8pa5";
      }
      {
        name = "cython";
        publisher = "tcwalther";
        version = "0.1.0";
        sha256 = "1xyly859f1h1a7mxqiyml90s6ryvbk3skqbxsjcyhpgmg5i9b17a";
      }
    ];
  in
  {
    vscode-with-extensions = prev.vscode-with-extensions.override {
      vscodeExtensions = marketplaceExtensions ++ (with prev.vscode-extensions; [
        bbenoist.nix # Nix syntax

        ms-vscode-remote.remote-ssh

        matklad.rust-analyzer
        github.copilot
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
        bungcip.better-toml
        tamasfe.even-better-toml
        ms-python.vscode-pylance

        # Nix
        brettm12345.nixfmt-vscode
        b4dm4n.vscode-nixpkgs-fmt

        skyapps.fish-vscode
        silvenon.mdx
        redhat.vscode-yaml
        ms-vscode.makefile-tools
        ms-vscode.cmake-tools
        mechatroner.rainbow-csv
        jnoortheen.nix-ide
        github.vscode-pull-request-github
        esbenp.prettier-vscode
        mkhl.direnv
      ]) ++ pkgs.lib.optionals (! (pkgs.stdenv.isAarch64 && pkgs.stdenv.isLinux)) (with prev.vscode-extensions; [
        ms-vscode.cpptools
        ms-python.python
        ms-vsliveshare.vsliveshare
        ms-azuretools.vscode-docker
      ]);
    };
  }
)
