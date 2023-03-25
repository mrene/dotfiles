{ config, lib, pkgs, ... }:
let
  ray-x-go-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "ray-x-go-nvim";
    version = "unstable-2023-03-23";
    src = pkgs.fetchFromGitHub {
      owner = "ray-x";
      repo = "go.nvim";
      rev = "c02634a8350d559eeed94f78c67016fa6d80a8bf";
      sha256 = "1bsc6zfrqxws2cqvf385wjjdhmxm2q15fg4hxf0hpkn9s6ipnkyy";
    };
  };

  ray-x-guihua = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "ray-x-guihua";
    version = "unstable-2023-02-16";
    src = pkgs.fetchFromGitHub {
      owner = "ray-x";
      repo = "guihua.lua";
      rev = "a19ac4447021f21383fadd7a9e1fc150d0b67e1f";
      sha256 = "0kl2ry3ngfwrw40igi2983gnmpmj78ipqm1wdlp7vphyh64a8lk4";
    };
  };

  nvim-lspconfig = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvim-lspconfig";
    version = "unstable-2023-03-24";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "f1392727d8ab6472b6463e875f553ebd32665d65";
      sha256 = "0ia6lmycvg8rrjbng33iqrmx1pqgsp66il7870zv899s12aspscp";
    };
    meta.homepage = "https://github.com/neovim/nvim-lspconfig/";
  };


  # Bleeding edge themes!
  catppuccin-nvim = pkgs.vimPlugins.catppuccin-nvim.overrideAttrs (old: {
    src = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "nvim";
      rev = "dc216c6241fd8439fe6018cca834200aca1a04ad";
      sha256 = "0vi00mqrf32a1fq76g4ry0vs63n1rc8hkbnljha7bz6vvk6yb1zz";
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
