{
  lib,
  inputs,
  ...
}:

let
  secrets = null;
  cfg = null;
  agenticEnabled = cfg == null || !cfg.minimalNvim;

  mkConfig =
    { pkgs, ... }:
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

      luaConfig =
        let
          confDir = ./conf;
        in
        ''
          -- Load config files in order
          local files = {
            '${confDir}/base.lua',
            '${confDir}/keymap.lua',
            '${confDir}/theme.lua',
            '${confDir}/buffers.lua',
            '${confDir}/windows.lua',
            '${confDir}/statusline.lua',
            '${confDir}/tree.lua',
            '${confDir}/sessions.lua',
            '${confDir}/notify.lua',
            '${confDir}/fzf.lua',
            '${confDir}/treesitter.lua',
            '${confDir}/git.lua',
            '${confDir}/lang.lua',
            '${confDir}/formatting.lua',
            '${confDir}/linting.lua',
            '${confDir}/copilot.lua',
            '${confDir}/diag.lua',
            '${confDir}/testing.lua',
            '${confDir}/quickfix.lua',
            '${confDir}/debugging.lua',
            '${confDir}/profiling.lua',
            ${lib.optionalString agenticEnabled "'${confDir}/agentic.lua',"}
          }

          for _, file in ipairs(files) do
            dofile(file)
          end
        '';

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

        inherit (neovimConfig) plugins extraPackages;
        extraLuaConfig = neovimConfig.luaConfig;
      };

      # Force load after the rest
      # May have to delete session if not working, or check `:scriptnames` / `:set runtimepath?`
      xdg.configFile."nvim/after/ftplugin" = {
        recursive = true;
        source = ./ftplugin;
      };
    };

  perSystem =
    { pkgs, ... }:
    {
      packages.nvim =
        let
          neovimConfig = mkConfig { inherit pkgs; };
        in

        pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
          inherit (neovimConfig) plugins extraPackages;
          luaRcContent = neovimConfig.luaConfig;
          runtimeDeps = neovimConfig.extraPackages;
          wrapperArgs = "--suffix PATH : ${lib.makeBinPath neovimConfig.extraPackages}";
        };

    };
}
