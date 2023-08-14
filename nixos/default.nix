{ inputs, self, config, ... }:

let
  overlayModule = config.flake.nixosModules.overlay;
in
{
  imports = [
    ./rpis
  ];

  flake.nixosConfigurations = {
    # sudo nixos-rebuild switch --flake .#beast
    beast = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit (self) common; inherit inputs; };
      modules = [ ./beast/configuration.nix overlayModule ];
    };

    # sudo nixos-rebuild switch --flake .#utm
    utm = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit (self) common; inherit inputs; };
      modules = [ ./utm/configuration.nix overlayModule ];
    };

    nas = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit (self) common; inherit inputs; };
      modules = [ ./nas/configuration.nix overlayModule ];
    };
  };
}
