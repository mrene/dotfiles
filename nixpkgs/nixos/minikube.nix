{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    minikube
    conntrack-tools
  ];
}
