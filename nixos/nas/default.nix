{
  inputs,
  config,
  self,
  ...
}:
{
  clan.machines.nas.imports = [
    ./configuration.nix
    config.flake.nixosModules.overlay
    config.flake.nixosModules.all
    config.flake.nixosModules.nas
  ];
}
