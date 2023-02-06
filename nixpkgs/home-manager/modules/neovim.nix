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

      # Theme
      nightfox-nvim

      # Goto anything
      ctrlp-vim

      # Git commit browser https://github.com/junegunn/gv.vim/
      gv-vim
      vim-fugitive
 
      # Tools
      nerdtree
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
      (builtins.readFile ./vim/plugin.nerdtree.vim)
      # (builtins.readFile ./vim/plugin.tmuxline.vim)
      (builtins.readFile ./vim/plugin.lualine.vim)
      (builtins.readFile ./vim/plugin.telescope.vim)
      (builtins.readFile ./vim/plugin.lsp.vim)
    ]);
  };
}
