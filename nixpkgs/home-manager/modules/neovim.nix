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
    version = "unstable-2023-02-11";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "27e6eb27f31d1ef41427e1008029284c02dc856f";
      sha256 = "1n1hz672vsxk26wrx4f904iif1lxmcap1lcb9wj081pgixwmh6np";
    };
    meta.homepage = "https://github.com/neovim/nvim-lspconfig/";
  };


  # Bleeding edge themes!
  catppuccin-nvim = pkgs.pkgsUnstable.vimPlugins.catppuccin-nvim.overrideAttrs(old: {
    src = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "nvim";
      rev = "4606b68140ee7003d32892fc297bce66e2348df2";
      hash = "sha256-KTtyMhKPBnRW3OLXWSLwJ9ZO2MyU5eZ1ZjlXgbmHEsQ=";
    };
  });

in
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      # UI
      lualine-nvim # https://github.com/nvim-lualine/lualine.nvim
      nvim-web-devicons
      lualine-lsp-progress
      # bufferline-nvim # Top bar 

      # Theme
      #nightfox-nvim
      catppuccin-nvim

      # Goto anything
      ctrlp-vim

      # Git commit browser https://github.com/junegunn/gv.vim/
      gv-vim
      vim-fugitive

      vim-gitgutter # Show diffs on the left of line numbers


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

      # Show LSP-aware context in file (current function, scope names)
      nvim-navic

      # needed by go-nvim
      # TODO: Trim down languages
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

      pkgs.pkgsUnstable.vimPlugins.copilot-lua
      pkgs.pkgsUnstable.vimPlugins.copilot-cmp

      # Debugger IDE
      vimspector

      # Start screen
      vim-startify

      # Github
      octo-nvim
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
      (builtins.readFile ./vim/plugin.octo.vim)
    ]);
  };

  # Create directory so startify can store its sessions
  xdg.dataFile."nvim/session/.keep".text = "";
}
