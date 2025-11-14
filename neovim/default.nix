{
  lib,
  inputs,
  ...
}:

let
  secrets = null;
  cfg = null;
  agenticEnabled = cfg == null || !cfg.minimalNvim;

  includeLuaFile = path: ''
    lua << END
    ${builtins.readFile ./conf/${path}}
    END
  '';

  mkConfig =
    {pkgs, ... }:
    let
        mcphub-nvim = inputs.mcphub-nvim.packages."${pkgs.stdenv.hostPlatform.system}".default;
        mcp-hub = inputs.mcp-hub.packages."${pkgs.stdenv.hostPlatform.system}".default;
    in
    {

      includeSecrets = lib.optionalString (secrets != null) ''
        if filereadable("${secrets.common.nvimSecrets}")
          lua dofile("${secrets.common.nvimSecrets}")
        else
          lua print("nvim secrets not found!!")
        endif
      '';

      plugins =
        (with pkgs.vimPlugins; [
          # Theme
          catppuccin-nvim
          nvim-web-devicons
          nvim-colorizer-lua # colorize hex codes, etc.

          # Layout
          nvim-tree-lua
          lualine-nvim # https://github.com/nvim-lualine/lualine.nvim
          auto-session # automatically restore last session
          zen-mode-nvim

          # Tools
          fzf-lua
          delimitMate # auto close quotes, parens, etc
          which-key-nvim # show keymap hints
          todo-comments-nvim # highlight TODO, FIXME, etc
          multicursors-nvim
          mini-nvim # tabline, bufremove, etc.
          snacks-nvim # profiler

          # Notifications
          (nvim-notify.overrideAttrs (_: {
            doCheck = false; # flaky on ci
          }))
          nvim-lsp-notify

          # Diagnostics
          trouble-nvim

          # Git
          vim-fugitive # Git (diff|log|...) commands
          gitsigns-nvim # Show git signs in gutter
          diffview-nvim # :DiffviewOpen, :DiffviewClose
          octo-nvim
          gitlinker-nvim

          # LSP / Languages
          go-nvim
          neotest
          neotest-golang
          neotest-python
          rustaceanvim
          conform-nvim # formatting
          nvim-navic # symbol breadcrumbs in statusline
          render-markdown-nvim
          nvim-lint

          # Autocomplete
          nvim-cmp # https://github.com/hrsh7th/nvim-cmp
          cmp-cmdline
          cmp-nvim-lsp
          cmp-nvim-lsp-signature-help
          cmp-nvim-lsp-document-symbol
          cmp-cmdline
          copilot-lua # use `Copilot auth` to login
          copilot-lsp # needed for NES on copilot-lua

          # Snippets
          luasnip
          cmp_luasnip
          friendly-snippets # easy load from vscode, languages, etc.

          # Debugging
          nvim-dap
          nvim-dap-ui
          nvim-dap-go
          nvim-dap-python
          nvim-dap-virtual-text

          # Syntax
          (nvim-treesitter.withPlugins (p: [
            # see https://github.com/nvim-treesitter/nvim-treesitter for available languages
            p.bash
            p.c
            p.comment
            p.css
            p.dockerfile
            p.dot
            p.fish
            p.go
            p.gomod
            p.gosum
            p.gotmpl
            p.gowork
            p.html
            p.javascript
            p.json
            p.jsonnet
            p.lua
            p.markdown
            p.markdown_inline
            p.nix
            p.proto
            p.python
            p.rust
            p.sql
            p.toml
            p.typescript
            p.vim
            p.vimdoc
            p.yaml
          ]))
          nvim-treesitter-textobjects # provides object manipulation
        ])
        ++ (lib.optionals agenticEnabled [
          pkgs.vimPlugins.codecompanion-nvim
          mcphub-nvim
          pkgs.vimPlugins.claudecode-nvim
        ]);

      extraConfig = (
        builtins.concatStringsSep "\n" (
          [
            (includeLuaFile "base.lua")
            # includeSecrets
            (includeLuaFile "keymap.lua")
            (includeLuaFile "theme.lua")
            (includeLuaFile "buffers.lua")
            (includeLuaFile "windows.lua")
            (includeLuaFile "statusline.lua")
            (includeLuaFile "tree.lua")
            (includeLuaFile "sessions.lua")
            (includeLuaFile "notify.lua")
            (includeLuaFile "fzf.lua")

            (includeLuaFile "treesitter.lua")
            (includeLuaFile "git.lua")
            (includeLuaFile "lang.lua")
            (includeLuaFile "formatting.lua")
            (includeLuaFile "linting.lua")

            (includeLuaFile "copilot.lua")

            (includeLuaFile "diag.lua")
            (includeLuaFile "testing.lua")
            (includeLuaFile "quickfix.lua")
            (includeLuaFile "debugging.lua")

            (includeLuaFile "profiling.lua")
          ]
          ++ (lib.optionals agenticEnabled [
            (includeLuaFile "agentic.lua")
          ])
        )
      );

      extraPackages =
        (with pkgs; [
          nixd # nix lsp

          marksman # markdown lsp
          markdownlint-cli # via nvim-lint

          nodejs # for copilot
          typescript-language-server

          stylua # lua formatting, `npx` for some MCPs
          lua-language-server # lua lsp

          bash-language-server # bash lsp
          shfmt # shell formatting (via lsp)
          shellcheck # shell linting (via lsp)

          rust-analyzer

          pyright
          ruff
          gh
        ])
        ++ (lib.optionals agenticEnabled [
          mcp-hub # via overlay
          pkgs.uv # for `uvx` for some MCPs
        ]);
    };
in
{
  flake.homeManagerModules.neovim =
    { pkgs, ... }:
    let
      neovimConfig = mkConfig { inherit pkgs; };
    in
    {
      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        defaultEditor = true;

        inherit (neovimConfig) plugins extraConfig extraPackages;
      };

      # Force load after the rest
      # May have to delete session if not working, or check `:scriptnames` / `:set runtimepath?`
      xdg.configFile."nvim/after/ftplugin" = {
        recursive = true;
        source = ./ftplugin;
      };
    };


  perSystem = { pkgs, ... }: {
    packages.nvim = let
      neovimConfig = mkConfig { inherit pkgs; };
    in

    (pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
      inherit (neovimConfig) plugins extraPackages;
      neovimRcContent = neovimConfig.extraConfig;
      runtimeDeps = neovimConfig.extraPackages;
      wrapperArgs = "--suffix PATH : ${lib.makeBinPath neovimConfig.extraPackages}";
    }); 
    
  };
}
