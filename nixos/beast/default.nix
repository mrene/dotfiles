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
    };
  };
}
