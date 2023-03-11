{ config, pkgs, ... }:

{
  imports = [ 
    ../common/common.nix 
    ../common/packages.nix
  ];

  boot.isContainer = true;
  boot.loader.initScript.enable = true;

  networking.hostName = ""; # empty
  networking.useDHCP = false;
  networking.useNetworkd = true;
  networking.useHostResolvConf = false;
  networking.firewall.enable = false;

# default password is "root", create with `openssl passwd -6 root`
  security.initialRootPassword = "$6$V1JB3DXzfkBBjaxL$V4ymu8BxUdDKwDqRMsy4bu4tyocBglz6qtuyonMbi.HweoKbcgLr.W57A62SPqi6CzEGWtER9vskXHAqoHpr4/";

  environment.systemPackages = with pkgs; [
     vim
     wget
  ];

  system.stateVersion = "23.05";
  nixpkgs.hostPlatform = "x86_64-linux";
}
