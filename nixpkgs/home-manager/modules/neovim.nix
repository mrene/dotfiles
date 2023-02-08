{ config, lib, pkgs, ... }:
let
  ray-x-go-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "ray-x-go-nvim";
    version = "2023-02-05";
    src = pkgs.fetchFromGitHub {
      owner = "ray-x";
      repo = "go.nvim";
      rev = "10349e1e430d00bc314c1d4abb043ac66ed219d9";
      hash = "sha256-oQmnhdypRWqnFeDBpyeeXb4UYDxgmZQuzdM+pyFDYZU=";
    };
  };

  ray-x-guihua = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "ray-x-guihua";
    version = "2023-02-05";
    src = pkgs.fetchFromGitHub {
      owner = "ray-x";
      repo = "guihua.lua";
      rev = "dca755457a994d99f3fe63ee29dbf8e2ac20ae3a";
      hash = "sha256-gz0hd8TyCLlZOnG5mfXdxKkXL3rpP8f3P3/X6jNa5c8=";
    };
  };

  nvim-lspconfig = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvim-lspconfig";
    version = "unstable-2023-02-06";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "d3c82d2f9a6fd91ec1ffee645664d2cc57e706d9";
      sha256 = "0kjqxhd4yqy799nnd743azj6c6v5q4g0j01sw4mp115yrqb7ffy0";
    };
    meta.homepage = "https://github.com/neovim/nvim-lspconfig/";
  };
in
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      # UI
      lualine-nvim # https://github.com/nvim-lualine/lualine.nvim
      lualine-lsp-progress
      # bufferline-nvim # Top bar 


      # Theme
      nightfox-nvim

      # Goto anything
      ctrlp-vim

      # Git commit browser https://github.com/junegunn/gv.vim/
      gv-vim
      vim-fugitive


      # Tools
      #nerdtree
      nvim-tree-lua # File tree
      project-nvim

      true-zen-nvim # zen mode

      nerdcommenter
      telescope-nvim # https://github.com/nvim-telescope/telescope.nvim
      toggleterm-nvim

      # Languages
      vim-nix
      vim-markdown
      vim-javascript
      typescript-vim
      nvim-lspconfig
      rust-tools-nvim
      ray-x-go-nvim
      ray-x-guihua
      lsp-inlayhints-nvim
      nvim-navic

      # needed by go-nvim
      pkgs.pkgsUnstable.vimPlugins.nvim-treesitter.withAllGrammars
      pkgs.pkgsUnstable.vimPlugins.nvim-treesitter-textobjects

      luasnip
      nvim-cmp # Auto-completion
      cmp_luasnip
      cmp-nvim-lsp
      cmp-nvim-lsp-signature-help
      cmp-nvim-lsp-document-symbol
      nvim-highlight-colors

      vim-flatbuffers
      fzf-vim
      zoxide-vim

      # Debugger IDE
      vimspector
    ] ++ lib.optionals (pkgs.stdenv.system != "aarch64-linux") [
      vim-go
    ];

    extraConfig = (builtins.concatStringsSep "\n" [
      (builtins.readFile ./vim/config.vim)
      (builtins.readFile ./vim/mappings.vim)
      (builtins.readFile ./vim/plugin.toggleterm.vim)
      (builtins.readFile ./vim/plugin.projectnvim.vim)
      (builtins.readFile ./vim/plugin.nvimtree.vim)
      (builtins.readFile ./vim/plugin.lualine.vim)
      (builtins.readFile ./vim/plugin.telescope.vim)
      (builtins.readFile ./vim/plugin.truezen.vim)
      (builtins.readFile ./vim/plugin.lsp.vim)
      (builtins.readFile ./vim/plugin.rust-tools.vim)
      (builtins.readFile ./vim/plugin.treesitter.vim)
    ]);
  };
}
