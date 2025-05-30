{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    secrets.url = "path:./secrets";
    appdots.url = "github:appaquet/dotfiles";
    appdots.inputs.secrets.follows = "secrets";
  };

  outputs = { flake-parts, appdots, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } ({ ... }: {
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      perSystem = { pkgs, system, ... }:
        let
          inherit (appdots.inputs) home-manager nixpkgs-unstable;
          appdots' = pkgs.runCommand "patched-appdots" { } ''
            mkdir $out
            cp -R ${appdots}/home-manager/modules/neovim/* $out
            sed -i 's/devMode = true/devMode = false/gi' $out/default.nix
          '';
          secrets = {
            common = {
              nvimSecrets = "";
            };
          };
          hm = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              "${appdots'}/default.nix"
              {
                home = {
                  username = "jdoe";
                  homeDirectory = "/home/jdoe";
                  stateVersion = "22.05";
                };
              }
            ];
            extraSpecialArgs = {
              inherit inputs;
              inherit secrets;
              unstablePkgs = import appdots.inputs.nixpkgs-unstable {
                inherit system overlays; 
              };
            };
          };
          cfg = hm.config.programs.neovim;
          lib = pkgs.lib;
          overlays = [
            (final: prev: 
              let
                flakeImport = inputName: packageName: appdots.inputs.${inputName}.packages.${prev.system}.${packageName};
              in
              {
                mcp-hub = flakeImport "mcp-hub" "default";
                mcphub-nvim = flakeImport "mcphub-nvim" "default";
              }
            )];

        in
        {
          _module.args.pkgs = import appdots.inputs.nixpkgs { 
            inherit system overlays; 
          };
          packages.default = (pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
            inherit (cfg) plugins;
            neovimRcContent = cfg.extraConfig;
            runtimeDeps = cfg.extraPackages;
            wrapperArgs = "--suffix PATH : ${lib.makeBinPath cfg.extraPackages}";
          });
        };
    });
}
