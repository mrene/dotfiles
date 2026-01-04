{
  config,
  ...
}:
{
  # Declare inputs used by this host for flake-file tracking
  flake-file.inputs.nixos-wsl = {
    url = "github:nix-community/NixOS-WSL";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  clan.machines.wsl.imports = with config.flake.modules.nixos; [
    core-base
    core-ssh-ca

    system-common-packages

    infra-distributed-builds
    infra-cachix

    wsl
    config.flake.nixosModules.overlay
  ];
}
