{
  config,
  ...
}:
{
  # Declare inputs used by this host for flake-file tracking
  flake-file.inputs.nixos-lima = {
    url = "github:ciderale/nixos-lima";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.disko.follows = "clan-core/disko";
  };

  clan.machines.utm.imports = [
    config.flake.modules.nixos.all
    config.flake.modules.nixos.utm
    config.flake.nixosModules.overlay
  ];
}
