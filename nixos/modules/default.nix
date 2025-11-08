{ pkgs, ... }:

{
  imports = [
    # Existing modules
    ./sops.nix
    ./restic.nix
    ./attic.nix
    ./caddy.nix
    ./dyndns.nix
    ./prs.nix
    ./brightness.nix
    ./screen-switch.nix

    # New refactored modules from common/
    # Core modules
    ./base.nix              # homelab.vm-common
    ./ssh-ca.nix            # homelab.ssh-ca
    ./common-packages.nix   # homelab.common-packages
    ./fonts.nix             # homelab.fonts

    # Hardware modules
    ./nvidia.nix            # homelab.nvidia
    ./radio.nix             # homelab.radio
    ./minikube.nix          # homelab.minikube
    ./distributed-builds.nix # homelab.distributed-builds
    ./cachix.nix            # homelab.cachix

    # GUI modules
    ./gui-base.nix          # homelab.gui.base
    ./gui-desktop.nix       # homelab.gui.desktop
    ./gui-dev.nix           # homelab.gui.dev
    ./gui-jetbrains.nix     # homelab.gui.jetbrains
    ./gui-messaging.nix     # homelab.gui.messaging

    # VM modules
    ./vm-qemu-guest.nix     # homelab.vm.qemu-guest
    ./vm-user.nix           # homelab.vm.common
  ];
}
