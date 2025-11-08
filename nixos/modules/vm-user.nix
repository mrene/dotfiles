{ lib, config, pkgs, common, ... }:

let
  cfg = config.homelab.vm.common;
in
{
  options.homelab.vm.common = {
    enable = lib.mkEnableOption "Enable homelab relaxed VM configuration (for VMs on trusted hardware)";
  };

  config = lib.mkIf cfg.enable {
    # Common relaxed configuration for use with VMs running on trusted hardware
    users = {
      users = {
        mrene = {
          isNormalUser = true;
          description = "mathieu";
          extraGroups = [
            "wheel"
            "docker"
            "networkmanager"
          ];
          openssh.authorizedKeys.keys = common.sshKeys;
          initialHashedPassword = "";
        };

        root.password = "nixos";
      };

      mutableUsers = true;
      defaultUserShell = pkgs.fish;
    };

    security.sudo.wheelNeedsPassword = false;

    services.openssh.enable = true;
    networking.networkmanager.enable = true;
  };
}
