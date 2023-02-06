{ config, lib, pkgs, ... }:
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
      rust-vim
      nvim-lspconfig

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
    ]);
  };
}
