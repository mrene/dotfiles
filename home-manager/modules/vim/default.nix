{ config, lib, pkgs, ... }:
let
  ray-x-go-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "ray-x-go-nvim";
    version = "unstable-2023-06-08";
    src = pkgs.fetchFromGitHub {
      owner = "ray-x";
      repo = "go.nvim";
      rev = "a8095eb334495caec3099b717cc7f5b1fbc3e628";
      sha256 = "1f21zyj875m4hk39ar2cd48mcw3z74wy436nkdfgiamibk03k77a";
    };
  };

  ray-x-guihua = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "ray-x-guihua";
    version = "unstable-2023-04-27";
    src = pkgs.fetchFromGitHub {
      owner = "ray-x";
      repo = "guihua.lua";
      rev = "ab8b1f09603cc268770efd057115035dc6cfa83d";
      sha256 = "125y0wnif8cicbsqrdw021gqgd9l29ml44jgk6apijrnja18ik4y";
    };
  };

  nvim-lspconfig = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvim-lspconfig";
    version = "unstable-2023-06-10";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "08f1f347c718e945c3b1712ebb68c6834182cf3a";
      sha256 = "0kqxbyb5hg6r4rv79bxjj8dvm3440137xxppp2a5idxi8sisdqad";
    };
    meta.homepage = "https://github.com/neovim/nvim-lspconfig/";
  };


  # Bleeding edge themes!
  catppuccin-nvim = pkgs.vimPlugins.catppuccin-nvim.overrideAttrs (old: {
    src = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "nvim";
      rev = "2df7036c5c303c9184869936e40ca18935e4afcb";
      sha256 = "0xv7694868023gdp0lxm08vv814cl9yw4nxwdk6sgvkk3za4kdin";
    };
  });

  nvim-navic = pkgs.vimPlugins.nvim-navic.overrideAttrs (old: {
    src = pkgs.fetchFromGitHub {
      owner = "SmiteshP";
      repo = "nvim-navic";
      rev = "15704c607569d6c5cfeab486d3ef9459645a70ce";
      sha256 = "0wsrpz61ndgi2imzyn18s69zixvbmky5j1h5srfgv2cxjzdm67gh";
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
      pkgs.vimPlugins.rust-tools-nvim
      ray-x-go-nvim
      ray-x-guihua
      lsp-inlayhints-nvim

      # Show LSP-aware context in file (current function, scope names)
      nvim-navic

      # needed by go-nvim
      # TODO: Trim down languages
      nvim-treesitter.withAllGrammars
      nvim-treesitter-textobjects


      luasnip
      nvim-cmp # Auto-completion
      cmp-cmdline
      cmp_luasnip
      cmp-nvim-lsp
      cmp-nvim-lsp-signature-help
      cmp-nvim-lsp-document-symbol
      nvim-highlight-colors

      vim-flatbuffers
      fzf-vim
      zoxide-vim

      copilot-lua
      copilot-cmp

      trouble-nvim

      # Debugger IDE
      #vimspector
      nvim-dap
      nvim-dap-ui
      nvim-dap-go
      nvim-dap-python
      nvim-dap-virtual-text
      plenary-nvim


      # Start screen
      vim-startify

      # Github
      octo-nvim
    ];

    extraConfig = (builtins.concatStringsSep "\n" [
      (builtins.readFile ./config.vim)
      (builtins.readFile ./mappings.vim)
      (builtins.readFile ./plugin.toggleterm.vim)
      (builtins.readFile ./plugin.projectnvim.vim)
      (builtins.readFile ./plugin.nvimtree.vim)
      (builtins.readFile ./plugin.lualine.vim)
      (builtins.readFile ./plugin.telescope.vim)
      (builtins.readFile ./plugin.truezen.vim)
      (builtins.readFile ./plugin.lsp.vim)
      (builtins.readFile ./plugin.rust-tools.vim)
      (builtins.readFile ./plugin.treesitter.vim)
      (builtins.readFile ./plugin.octo.vim)
      (builtins.readFile ./plugin.trouble.vim)
    ]);
  };

  # Create directory so startify can store its sessions
  xdg.dataFile."nvim/session/.keep".text = "";
}
