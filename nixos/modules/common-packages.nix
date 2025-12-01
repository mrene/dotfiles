{ lib, inputs, ... }:
{
  flake.nixosModules.all =
    { config, pkgs, ... }:
    let
      cfg = config.homelab.common-packages;
    in
    {
      imports = [
        # Include modules that aren't enabled-by-default
        inputs.minidsp.nixosModules.default
        inputs.nix-index-database.nixosModules.nix-index
      ];

      options.homelab.common-packages = {
        enable = lib.mkEnableOption "Enable homelab common package set";
      };

      config = lib.mkIf cfg.enable {
        programs.command-not-found.enable = false; # conflicts with nix-index
        environment.systemPackages = with pkgs; [
          wget
          curl
          direnv
          nix-direnv
          git
          zip
          unzip

          usbutils
          pciutils
          lm_sensors
          lshw
          file
          lsof
          unixtools.xxd

          yq-go
          jq

          btop
          man-pages
          sysstat
          dool
          dtool
          bat
          eza
          fd
          tmux-xpanes
          ipset
          iptables
          ethtool
        ];

        programs.mtr.enable = true;

        #programs.neovim = {
        #enable = true;
        #viAlias = true;
        #vimAlias = true;
        #};
      };
    };
}
