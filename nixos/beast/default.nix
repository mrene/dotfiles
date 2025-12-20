{
  inputs,
  config,
  self,
  ...
}:
{
  clan = {
    # TODO: Move global opts
    meta.name = "tailc705a";
    meta.domain = "tailc705a.ts.net";

    specialArgs = {
      inherit (self) common;
      inherit inputs self;
      flakePackages = config.flake.packages;
    };

    machines.beast = {
      imports = [
        ./configuration.nix
        self.nixosModules.overlay
        self.nixosModules.all
      ];
      # nixpkgs.hostPlatform = "x86_64-linux"; # TODO: Why must this be redefined?
    };
  };

  # flake.nixosConfigurations.beast = inputs.nixpkgs.lib.nixosSystem {
  #   specialArgs = {
  #     inherit (self) common;
  #     inherit inputs self;
  #     flakePackages = config.flake.packages;
  #   };
  #   modules = [
  #     ./configuration.nix
  #     config.flake.nixosModules.overlay
  #     config.flake.nixosModules.all
  #     # ^ these are imported via the clan module
  #     # self.clan.nixosModules.clan-machine-beast
  #   ];
  # };
}
