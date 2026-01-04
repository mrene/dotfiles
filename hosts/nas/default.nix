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

    services-sops
    services-restic
    services-attic
    services-caddy
    services-dyndns
    services-forgejo
    services-prs

    nas

    config.flake.nixosModules.overlay
  ];
}
