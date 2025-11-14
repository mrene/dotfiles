{inputs, ...}: {
  imports = [
    inputs.devshell.flakeModule
  ];

  perSystem = {
    system,
    pkgs,
    ...
  }: {
    devshells.default = {
      commands = [
        {
          name = "update-all";
          command = "update-git && update-sources && update-flake";
          help = "Run all update commands";
        }
        {
          name = "update-flake";
          command = "nix flake update";
          help = "Updates flake references";
        }
        {
          name = "update-git";
          command = "update-nix-fetchgit $(rg --files-with-matches fetchFrom $PRJ_ROOT)";
          help = "Update git fetch expressions";
        }
        {
          name = "update-package";
          command = "nix-update -F $1";
          help = "<package> Updates local package (from packages/) using nix-update";
        }
        {
          name = "update-sources";
          command = "nvfetcher";
          help = "Updates all sources defined in nvfetcher.toml";
        }
      ];

      packages = [
        inputs.nix-update.packages.${system}.default
        pkgs.nvfetcher
        pkgs.sops
        pkgs.ssh-to-age
        pkgs.age
      ];
    };

    devShells.esp = pkgs.mkShell {
      packages = [ pkgs.esphome ];
    };

    devShells.installer = pkgs.mkShell {
      buildInputs = with pkgs; lib.optionals pkgs.stdenv.hostPlatform.isLinux [
        nixos-install-tools
      ];
    };
  };
}
