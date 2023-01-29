{ config, lib, pkgs, modulesPath, ... }:
{
  fileSystems."/" =
    { device = "none";
      fsType = "tmpfs";
      options = [ "size=8G" "mode=755" ]; # mode=755 so only root can write to those files
    };

  fileSystems."/nix/store" = {
    device = "/ubuntu/nix/store";
    options = [ "bind" "ro" ];
    neededForBoot = true;
  };
}
