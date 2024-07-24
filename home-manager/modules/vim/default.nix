{pkgs, ...}: let
  ray-x-go-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "ray-x-go-nvim";
    version = "unstable-2024-07-16";
    src = pkgs.fetchFromGitHub {
      owner = "ray-x";
      repo = "go.nvim";
      rev = "033344ddfa3cd5cfd55037903264b2bb86691619";
      sha256 = "15i8699kw32liq82632ngc1bfr1vasy8f8wag7im1kin9s8bw5c3";
    };
  };

  ray-x-guihua = pkgs.vimUtils.buildVimPlugin {
    pname = "ray-x-guihua";
    version = "unstable-2024-06-05";
    src = pkgs.fetchFromGitHub {
      owner = "ray-x";
      repo = "guihua.lua";
      rev = "225db770e36aae6a1e9e3a65578095c8eb4038d3";
      sha256 = "1in4hnmizik453zym9lh9an3xmim9k52vzj99z00i1k524wyb6jp";
    };
  };

  nvim-lspconfig = pkgs.vimUtils.buildVimPlugin {
    pname = "nvim-lspconfig";
    version = "unstable-2024-07-22";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "fa6c2a64100c6f692bbec29bbbc8ec2663c9e869";
      sha256 = "1kpbv2fkrqpfwjjq8sz1m5vy4aqlsa2x1izz4ig8lv56zjcsb4d2";
    };
    meta.homepage = "https://github.com/neovim/nvim-lspconfig/";
  };

  # Bleeding edge themes!
  catppuccin-nvim = pkgs.vimPlugins.catppuccin-nvim.overrideAttrs (_old: {
    src = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "nvim";
      rev = "0b5df9c9e641b1212b21a0762ccad4434fd41322";
      sha256 = "194b1i8nkfg16gnwf3a1hkk9dbidvldz7p6n1bf212j76x08j4i6";
    };
  });

  nvim-navic = pkgs.vimPlugins.nvim-navic.overrideAttrs (_old: {
    src = pkgs.fetchFromGitHub {
      owner = "SmiteshP";
      repo = "nvim-navic";
      rev = "8649f694d3e76ee10c19255dece6411c29206a54";
      sha256 = "0964wgwh6i4nm637vx36bshkpd5i63ipwzqmrdbkz5h9bzyng7nj";
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
