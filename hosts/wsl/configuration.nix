{ inputs, ... }:
{
  flake.modules.nixos.wsl =
    {
      config,
      lib,
      pkgs,
      inputs,
      self,
      ...
    }:
    {
      imports = [
        inputs.nixos-wsl.nixosModules.default
        inputs.home-manager.nixosModules.home-manager
      ];

      wsl.enable = true;
      wsl.defaultUser = "mrene";
      wsl.useWindowsDriver = true;

      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          mesa
          libvdpau-va-gl
        ];
      };

      users.defaultUserShell = pkgs.fish;

      programs.nix-ld.enable = true;
      environment.variables = {
        NIX_LD_LIBRARY_PATH = lib.mkForce "/run/current-system/sw/share/nix-ld/lib:/usr/lib/wsl/lib";
      };

      home-manager = {
        users.mrene = {
          imports = with self.modules.homeManager; [
            # Core
            core-minimal
            core-ssh

            # Shell
            shell-fish

            # Dev
            dev-git
            dev-jujutsu

            # System
            system-common

            # Host-specific
            wsl
          ];
        };
        useGlobalPkgs = true;
        verbose = true;
        extraSpecialArgs = { inherit inputs self; };
        backupFileExtension = "hmbak";
      };

      system.stateVersion = "24.11";
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    };
}
