{ ... }: 

{
  imports = [
    ./openthread-border-router
    ./sops.nix
    ./restic.nix
    ./attic.nix
    ./caddy.nix
  ];
}
