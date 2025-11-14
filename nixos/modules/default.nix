{ pkgs, ... }: 

{
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
  ];
}
