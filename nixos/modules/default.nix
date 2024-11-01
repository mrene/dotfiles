{ pkgs, ... }: 

{
  imports = [
    ./sops.nix
    ./restic.nix
    ./attic.nix
    ./caddy.nix
    ./dyndns.nix
    ./prs.nix
    ./brightness.nix
  ];
}
