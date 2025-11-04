{pkgs, ...}: let
  # ray-x-go-nvim = pkgs.vimUtils.buildVimPlugin {
  #   pname = "ray-x-go-nvim";
  #   version = "unstable-2024-12-01";
  #   src = pkgs.fetchFromGitHub {
  #     owner = "ray-x";
  #     repo = "go.nvim";
  #     rev = "c6d5ca26377d01c4de1f7bff1cd62c8b43baa6bc";
  #     sha256 = "1vx86g8lgyhg7wa4azl4hajzh42hvb1a1q9ndihwb1v4dy5bizxf";
  #   };
  # };

  # ray-x-guihua = pkgs.vimUtils.buildVimPlugin {
  #   pname = "ray-x-guihua";
  #   version = "unstable-2024-11-02";
  #   src = pkgs.fetchFromGitHub {
  #     owner = "ray-x";
  #     repo = "guihua.lua";
  #     rev = "d783191eaa75215beae0c80319fcce5e6b3beeda";
  #     sha256 = "1zh3aq7bspyd1danbwzsvrvn95xx9qkyj0jgr3dkg82v7mp2r5ay";
  #   };
  # };

  nvim-lspconfig = pkgs.vimUtils.buildVimPlugin {
    pname = "nvim-lspconfig";
    version = "unstable-2025-11-03";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "2010fc6ec03e2da552b4886fceb2f7bc0fc2e9c0";
      sha256 = "1lb85magzq9kghp9xkcxr0lnz975qkfvczk5i4d1q2i7yxzfns9l";
    };
    meta.homepage = "https://github.com/neovim/nvim-lspconfig/";
  };

  # Bleeding edge themes!
  catppuccin-nvim = pkgs.vimPlugins.catppuccin-nvim.overrideAttrs (_old: {
    src = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "nvim";
      rev = "234fc048de931a0e42ebcad675bf6559d75e23df";
      sha256 = "0m6lg9fifx6izj6572jp0a5klmdly019hg2parvlqfyxwlksxlsq";
    };
  });

  nvim-navic = pkgs.vimPlugins.nvim-navic.overrideAttrs (_old: {
    src = pkgs.fetchFromGitHub {
      owner = "SmiteshP";
      repo = "nvim-navic";
      rev = "099b4c8cdc3e9ea026ea6b2a0d315e2d28362242";
      sha256 = "0ghr4p4qjy8q6qc249mwws8ndq2xdyqjcp2myazdbdm709xgapi6";
    };
  });
in {
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
      # ray-x-go-nvim
      # ray-x-guihua
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

    extraConfig = builtins.concatStringsSep "\n" [
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
    ];
  };

  # Create directory so startify can store its sessions
  xdg.dataFile."nvim/session/.keep".text = "";
}
