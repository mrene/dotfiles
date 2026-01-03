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

  clan.machines.wsl.imports = [
    config.flake.modules.nixos.all
    config.flake.modules.nixos.wsl
    config.flake.nixosModules.overlay
  ];
}
