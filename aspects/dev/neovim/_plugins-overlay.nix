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
      version = "unstable-2025-12-30";
      src = prev.fetchFromGitHub {
        owner = "copilotlsp-nvim";
        repo = "copilot-lsp";
        rev = "1b6d8273594643f51bb4c0c1d819bdb21b42159d";
        sha256 = "0wxz3sxkg145k584dh5f52zpf3l2a7mgn251a3ih30hlhfj9dgn1";
      };
      meta.homepage = "https://github.com/copilotlsp-nvim/copilot-lsp/";
      meta.hydraPlatforms = [ ];
    };

    # https://github.com/zbirenbaum/copilot.lua
    copilot-lua = prev.vimUtils.buildVimPlugin {
      pname = "copilot.lua";
      version = "unstable-2026-05-15";
      src = prev.fetchFromGitHub {
        owner = "zbirenbaum";
        repo = "copilot.lua";
        rev = "407349117f176789df6ec1c23bca72f34e15b4e8";
        sha256 = "0jnhvndjzj3k3kh83nq3dvwvj6x9yyyyfcyfpvnjyr8r1lx3h57s";
      };
      meta.homepage = "https://github.com/zbirenbaum/copilot.lua/";
      meta.hydraPlatforms = [ ];
    };

    # https://github.com/nvim-neotest/neotest
    neotest = prev.vimUtils.buildVimPlugin {
      pname = "neotest";
      version = "unstable-2025-11-08";
      src = prev.fetchFromGitHub {
        owner = "appaquet";
        repo = "neotest";
        rev = "deadfb1af5ce458742671ad3a013acb9a6b41178";
        sha256 = "0qiff2cg7dz96mvfihgb9rgmg0zsjf95nvxnfnzw0pnp65ch4bnh";
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
      version = "unstable-2026-04-25";
      src = prev.fetchFromGitHub {
        owner = "fredrikaverpil";
        repo = "neotest-golang";
        rev = "84c1f3be59f85a2f5bbb9290040077bc8a68a00c";
        sha256 = "15khrw5jzi1ks0r029vx47naka0rjn5js4y395rzcy080c399sdk";
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
      version = "unstable-2026-04-05";
      src = prev.fetchFromGitHub {
        owner = "nvim-neotest";
        repo = "neotest-python";
        rev = "e6df4f1892f6137f58135917db24d1655937d831";
        sha256 = "0lcfkwhdkwrj598hj7rlp8rvfamm8r10z3jp4f0ipvdxlb9bjjsd";
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
