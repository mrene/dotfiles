# REFACTOR PLAN: This file will become:
#   - homelab.minikube.enable
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    minikube
    conntrack-tools
  ];
}
