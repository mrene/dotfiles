{ ... }: 

{
  imports = [
    ./openthread-border-router
    ./sops.nix
    ./restic.nix
  ];
}
