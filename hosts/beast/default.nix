{
  inputs,
  config,
  self,
  ...
}:
{
  clan = {
    meta.name = "tailc705a";
    meta.domain = "tailc705a.ts.net";

    specialArgs = {
      inherit (self) common;
      inherit inputs self;
      flakePackages = config.flake.packages;
    };

    machines.beast = {
      imports = [
        config.flake.modules.nixos.all
        config.flake.modules.nixos.beast
        self.nixosModules.overlay
      ];
    };
  };
}
