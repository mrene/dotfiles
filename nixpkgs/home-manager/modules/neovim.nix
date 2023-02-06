{ config, lib, pkgs, ... }:
let
  ray-x-go-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "vim-better-whitespace";
    src = pkgs.fetchFromGitHub {
      owner = "ray-x";
      repo = "go.nvim";
      rev = "10349e1e430d00bc314c1d4abb043ac66ed219d9";
      hash = "sha256-oQmnhdypRWqnFeDBpyeeXb4UYDxgmZQuzdM+pyFDYZU=";
    };
  };
in
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      # UI
      lualine-nvim  # https://github.com/nvim-lualine/lualine.nvim
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
      nvim-tree-lua  # File tree
      project-nvim

      true-zen-nvim # zen mode

      nerdcommenter
      telescope-nvim # https://github.com/nvim-telescope/telescope.nvim

      # Languages
      vim-nix
      vim-markdown
      vim-javascript
      typescript-vim
      nvim-lspconfig
      rust-tools-nvim
      ray-x-go-nvim

      luasnip
      nvim-cmp # Auto-completion
      cmp_luasnip
      cmp-nvim-lsp
      cmp-nvim-lsp-signature-help
      cmp-nvim-lsp-document-symbol
      nvim-highlight-colors

      # Debugger IDE
      vimspector
    ] ++ lib.optionals (pkgs.stdenv.system != "aarch64-linux") [
      vim-go
    ];

    extraConfig = (builtins.concatStringsSep "\n" [
      (builtins.readFile ./vim/config.vim)
      (builtins.readFile ./vim/mappings.vim)
      (builtins.readFile ./vim/plugin.go.vim)
      (builtins.readFile ./vim/plugin.projectnvim.vim)
      (builtins.readFile ./vim/plugin.nvimtree.vim)
      (builtins.readFile ./vim/plugin.lualine.vim)
      (builtins.readFile ./vim/plugin.telescope.vim)
      (builtins.readFile ./vim/plugin.truezen.vim)
      (builtins.readFile ./vim/plugin.lsp.vim)
      (builtins.readFile ./vim/plugin.rust-tools.vim)
      (builtins.readFile ./vim/plugin.go.vim)
    ]);
  };
}
