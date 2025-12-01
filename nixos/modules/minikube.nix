{ lib, ... }:
{
  flake.nixosModules.all =
    { config, pkgs, ... }:
    let
      cfg = config.homelab.minikube;
    in
    {
      options.homelab.minikube = {
        enable = lib.mkEnableOption "Enable homelab minikube and related tools";
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
          minikube
          conntrack-tools
        ];
      };
    };
}
