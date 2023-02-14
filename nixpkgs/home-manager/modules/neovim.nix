{ config, lib, pkgs, ... }:
let
  ray-x-go-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "ray-x-go-nvim";
    version = "unstable-2023-02-12";
    src = pkgs.fetchFromGitHub {
      owner = "ray-x";
      repo = "go.nvim";
      rev = "4977d3165d6ee8a06781f7b3443484fe7e91c9a3";
      sha256 = "1ghy0xg9pkcif580gqd3l1vmzp0ilnlxnzssij65cnh04hr99y62";
    };
  };

  ray-x-guihua = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "ray-x-guihua";
    version = "unstable-2023-02-12";
    src = pkgs.fetchFromGitHub {
      owner = "ray-x";
      repo = "guihua.lua";
      rev = "5cebe5bd6ce1820cab526f4ba5876d441a752460";
      sha256 = "1hkw7h6lzvfv63viqnlphcrlk7m6zj4d09sv32rjyn1a8pwjhdv3";
    };
  };

  nvim-lspconfig = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvim-lspconfig";
    version = "unstable-2023-02-12";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "1712672e4da3003a0dd9f771d30389600b360f42";
      sha256 = "18dpijknw3w82rag39acw60vwc6q0apc8hm82x6103gqsimcs3as";
    };
    meta.homepage = "https://github.com/neovim/nvim-lspconfig/";
  };


  # Bleeding edge themes!
  catppuccin-nvim = pkgs.pkgsUnstable.vimPlugins.catppuccin-nvim.overrideAttrs(old: {
    src = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "nvim";
      rev = "a5f3ed5d3b1d9ea21183718a8a89a6653bd6ea48";
      sha256 = "1vx7p3f8339v1w9ww9l1lg3s6wf699q2bp762aqkmwmh88ykhi8i";
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
      pkgs.pkgsUnstable.vimPlugins.rust-tools-nvim
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
      #vimspector
      nvim-dap
      nvim-dap-ui
      nvim-dap-go
      nvim-dap-python
      plenary-nvim


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
