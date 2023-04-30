{ config, lib, pkgs, ... }:
let
  ray-x-go-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "ray-x-go-nvim";
    version = "unstable-2023-04-24";
    src = pkgs.fetchFromGitHub {
      owner = "ray-x";
      repo = "go.nvim";
      rev = "80670b233218e9c72e9c8893ba52aff4b7510947";
      sha256 = "19smjfa3zz9864dhp2pfxv05llh4rdaz8cksfvpaq4ja7j6vb3n0";
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
    version = "unstable-2023-04-27";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "427378a03ffc1e1bc023275583a49b1993e524d0";
      sha256 = "0f7jiryclg32nia7wciz58cj974jx5xhmiq43wcyidf7nfm62rwb";
    };
    meta.homepage = "https://github.com/neovim/nvim-lspconfig/";
  };


  # Bleeding edge themes!
  catppuccin-nvim = pkgs.vimPlugins.catppuccin-nvim.overrideAttrs (old: {
    src = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "nvim";
      rev = "3e91672945ae882098556cbade4f47987e6bae6b";
      sha256 = "1syiqraqm5s4ka2d1ciz0v05gcnpnpj181ki90x0p66vbysblnzr";
    };
  });

  nvim-navic = pkgs.vimPlugins.nvim-navic.overrideAttrs (old: {
    src = pkgs.fetchFromGitHub {
      owner = "SmiteshP";
      repo = "nvim-navic";
      rev = "83dc174da915f9dbc9b51169e9b62a2e0d42b527";
      sha256 = "19lr5mlhnfd9s47mvhhkxl343slsvhw8ni5gqb9p11k1zznl2h9b";
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
