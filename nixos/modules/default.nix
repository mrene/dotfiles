{ ... }: 

{
  imports = [
    ./openthread-border-router.nix
    ./sops.nix
    ./restic.nix
    ./attic.nix
    ./caddy.nix
    ./dyndns.nix
  ];
}
