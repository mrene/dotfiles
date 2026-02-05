final: prev: {
  vimPlugins = prev.vimPlugins // {
    # Forked from https://github.com/mrded/nvim-lsp-notify
    nvim-lsp-notify = prev.vimUtils.buildVimPlugin {
      name = "lsp-notify";
      src = ./plugins/lsp-notify;
    };

    # https://github.com/copilotlsp-nvim/copilot-lsp
    copilot-lsp = prev.vimUtils.buildVimPlugin {
      pname = "copilot-lsp";
      version = "2025-10-01";
      src = prev.fetchFromGitHub {
        owner = "copilotlsp-nvim";
        repo = "copilot-lsp";
        rev = "884034b23c3716d55b417984ad092dc2b011115b";
        sha256 = "sha256-g9/yQ7wsyJQHCp+nKTy5WFGoHPtXEEIMwfyuCasmHTY=";
      };
      meta.homepage = "https://github.com/copilotlsp-nvim/copilot-lsp/";
      meta.hydraPlatforms = [ ];
    };

    # https://github.com/zbirenbaum/copilot.lua
    copilot-lua = prev.vimUtils.buildVimPlugin {
      pname = "copilot.lua";
      version = "2026-01-28";
      src = prev.fetchFromGitHub {
        owner = "zbirenbaum";
        repo = "copilot.lua";
        rev = "9b8d77c6c847c83c784c05f5f86b4821ed90d3a1";
        sha256 = "sha256-nvGt/u4K5iYi7AZegV/tpOjFNlye7+LYPMejuuIwJ0M=";
      };
      meta.homepage = "https://github.com/zbirenbaum/copilot.lua/";
      meta.hydraPlatforms = [ ];
    };

    # https://github.com/nvim-neotest/neotest
    neotest = prev.vimUtils.buildVimPlugin {
      pname = "neotest";
      version = "5.13.1-patched2";
      src = prev.fetchFromGitHub {
        owner = "appaquet";
        repo = "neotest";
        rev = "fix/add-subprocess-default-init-back";
        sha256 = "sha256-UVXje4ENyKtLbL8lWrnacYdHFqE/rEiHkOhGzdwpN1U=";
      };
      propagatedBuildInputs = with prev.vimPlugins; [
        nvim-nio
        plenary-nvim
      ];
      doCheck = false;
      meta.homepage = "https://github.com/nvim-neotest/neotest";
    };

    # https://github.com/fredrikaverpil/neotest-golang
    neotest-golang = prev.vimUtils.buildVimPlugin {
      pname = "neotest-golang";
      version = "2.7.2";
      src = prev.fetchFromGitHub {
        owner = "fredrikaverpil";
        repo = "neotest-golang";
        rev = "v2.7.2";
        sha256 = "sha256-oZWb6GsZTgclKFyDgZWWANmfPRjg0LZgFymQs2SC8Rc=";
      };
      propagatedBuildInputs = [
        final.vimPlugins.neotest # Use our custom neotest from this overlay
      ];
      doCheck = false;
      meta.homepage = "https://github.com/fredrikaverpil/neotest-golang/";
    };

    # https://github.com/nvim-neotest/neotest-python
    neotest-python = prev.vimUtils.buildVimPlugin {
      pname = "neotest-python";
      version = "2025-11-04";
      src = prev.fetchFromGitHub {
        owner = "nvim-neotest";
        repo = "neotest-python";
        rev = "b0d3a861bd85689d8ed73f0590c47963a7eb1bf9";
        sha256 = "sha256-3rK561yVzrof0WKxsKfVPeOazShllkPRVqnguNQs/x4=";
      };
      propagatedBuildInputs = [
        final.vimPlugins.neotest # Use our custom neotest from this overlay
      ];
      doCheck = false;
      meta.homepage = "https://github.com/nvim-neotest/neotest-python/";
      meta.hydraPlatforms = [ ];
    };
  };
}
