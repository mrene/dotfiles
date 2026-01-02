{
  inputs,
  config,
  self,
  ...
}:
{
  clan.machines.nas.imports = [
    config.flake.modules.nixos.nas
    config.flake.nixosModules.overlay
    config.flake.modules.nixos.all
  ];
}
