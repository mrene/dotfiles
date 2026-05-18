{
  inputs,
  config,
  self,
  ...
}:
{
  clan.machines.nas.imports = with config.flake.modules.nixos; [
    core-base
    core-ssh-ca

    system-common-packages

    hardware-nvidia

    infra-distributed-builds
    infra-cachix
    infra-syncthing

    services-sops
    services-restic
    services-dyndns
    services-prs
    services-homelab

    nas

    config.flake.nixosModules.overlay
    config.flake.nixosModules.hmUnstable
  ];
}
