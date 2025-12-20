final: prev: {
  vimPlugins = prev.vimPlugins // {
    # Forked from https://github.com/mrded/nvim-lsp-notify
    nvim-lsp-notify = prev.vimUtils.buildVimPlugin {
      name = "lsp-notify";
      src = ./plugins/lsp-notify;
    };

    copilot-lsp = prev.vimUtils.buildVimPlugin {
      pname = "copilot-lsp";
      version = "unstable-2025-11-10";
      src = prev.fetchFromGitHub {
        owner = "copilotlsp-nvim";
        repo = "copilot-lsp";
        rev = "884034b23c3716d55b417984ad092dc2b011115b";
        sha256 = "0dhx4smhkbpwq464442pzcfahlaqp4y2k9wz183r9j1cpi1z5pw3";
      };
      meta.homepage = "https://github.com/copilotlsp-nvim/copilot-lsp/";
      meta.hydraPlatforms = [ ];
    };

    copilot-lua = prev.vimUtils.buildVimPlugin {
      pname = "copilot.lua";
      version = "unstable-2025-12-20";
      src = prev.fetchFromGitHub {
        owner = "zbirenbaum";
        repo = "copilot.lua";
        rev = "e78d1ffebdf6ccb6fd8be4e6898030c1cf5f9b64";
        sha256 = "103cn19lkpd2lianl150fagipim5a5w06m3wmj0ra9jl8pkp9gzk";
      };
      meta.homepage = "https://github.com/zbirenbaum/copilot.lua/";
      meta.hydraPlatforms = [ ];
    };

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

    neotest-golang = prev.vimUtils.buildVimPlugin {
      pname = "neotest-golang";
      version = "unstable-2025-12-11";
      src = prev.fetchFromGitHub {
        owner = "fredrikaverpil";
        repo = "neotest-golang";
        rev = "37e400cfe9d193e508b1a512e96cbef83b08deb6";
        sha256 = "05749a7xpfrngn8qbpw4dbghqq1z5zrlnx0bgq5wc1ssn8jv5238";
      };
      propagatedBuildInputs = [
        final.vimPlugins.neotest # Use our custom neotest from this overlay
      ];
      doCheck = false;
      meta.homepage = "https://github.com/fredrikaverpil/neotest-golang/";
    };

    neotest-python = prev.vimUtils.buildVimPlugin {
      pname = "neotest-python";
      version = "unstable-2025-10-13";
      src = prev.fetchFromGitHub {
        owner = "nvim-neotest";
        repo = "neotest-python";
        rev = "b0d3a861bd85689d8ed73f0590c47963a7eb1bf9";
        sha256 = "07pz5kabiq59av8l75k5536rmqrxsnkv1cb2s4gvmklmbkmvkcny";
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
