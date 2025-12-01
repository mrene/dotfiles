{
  # Import all NixOS modules as flake-parts modules
  # Each module contributes to flake.nixosModules.all (merged by flake-parts)
  imports = [
    ./sops.nix
    ./restic.nix
    ./attic.nix
    ./caddy.nix
    ./dyndns.nix
    ./forgejo.nix
    ./prs.nix
    ./brightness.nix
    ./screen-switch.nix
    ./kanidm.nix

    # Core modules
    ./base.nix
    ./ssh-ca.nix
    ./common-packages.nix
    ./fonts.nix

    # Hardware modules
    ./nvidia.nix
    ./radio.nix
    ./minikube.nix
    ./distributed-builds.nix
    ./cachix.nix

    # GUI modules
    ./gui-base.nix
    ./gui-desktop.nix
    ./gui-dev.nix
    ./gui-jetbrains.nix
    ./gui-messaging.nix

    # VM modules
    ./vm-qemu-guest.nix
    ./vm-user.nix
  ];
}
