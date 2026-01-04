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

  clan.machines.utm.imports = with config.flake.modules.nixos; [
    core-base
    core-ssh-ca

    system-common-packages

    infra-minikube
    infra-vm-user

    utm
    config.flake.nixosModules.overlay
  ];
}
