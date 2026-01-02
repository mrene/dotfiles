# This aspect bundles all other aspects together using flake-aspects includes.
# Hosts can import `self.modules.nixos.all` or `self.modules.homeManager.all`
# to get all aspect modules at once.
{ ... }:
{
  flake.aspects =
    { aspects, ... }:
    {
      all = {
        # Empty modules that will have includes resolved into them
        nixos = { };
        homeManager = { };
        includes = with aspects; [
          # Core
          core-base
          core-ssh-ca
          core-minimal
          core-ssh

          # Desktop
          desktop-fonts
          desktop-gui-base
          desktop-gui-desktop
          desktop-gui-messaging
          desktop-gnome
          desktop-hyprland
          desktop-rofi

          # Dev
          dev-gui-dev
          dev-gui-jetbrains
          dev-git
          dev-jujutsu
          dev-vscode-server

          # Hardware
          hardware-brightness
          hardware-nvidia
          hardware-radio
          hardware-screen-switch
          hardware-rgb

          # Infra
          infra-cachix
          infra-distributed-builds
          infra-minikube
          infra-vm-qemu-guest
          infra-vm-user

          # Services
          services-attic
          services-caddy
          services-dyndns
          services-forgejo
          services-kanidm
          services-prs
          services-restic
          services-sops

          # Shell
          shell-fish
          shell-fish-ai
          shell-wezterm
          shell-zellij

          # System
          system-common
          system-common-packages
          system-neofetch

          # Work
          work-jira
        ];
      };
    };
}
