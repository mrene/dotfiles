{ lib, ... }:
{
  flake.aspects.infra-vm-user.nixos =
    {
      pkgs,
      common,
      ...
    }:
    {
        # Common relaxed configuration for use with VMs running on trusted hardware
        users = {
          users = {
            mrene = lib.mkDefault {
              isNormalUser = true;
              description = "mathieu";
              extraGroups = [
                "wheel"
                "docker"
                "networkmanager"
              ];
              openssh.authorizedKeys.keys = common.sshKeys;
              initialHashedPassword = "$y$j9T$AcnJBxSOCjZeYq9fr0xrs1$KKmMGKzMhdg82/JvXVmT5PeFnco9q2HGNmRkrXqfHQ7";
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
