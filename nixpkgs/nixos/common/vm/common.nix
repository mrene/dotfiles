# Common relaxed configuration for use with VMs running on trusted hardware

{ common, pkgs, ... }: 

{
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
}