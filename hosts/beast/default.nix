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
      imports = with config.flake.modules.nixos; [
        # Core
        core-base
        core-ssh-ca

        # System
        system-common-packages

        # Desktop
        desktop-fonts
        desktop-gui

        # Hardware
        hardware-nvidia
        hardware-radio
        hardware-brightness
        hardware-screen-switch

        # Infra
        infra-minikube
        infra-distributed-builds
        infra-cachix

        # Dev
        dev-gui

        # Services
        services-sops
        services-restic
        services-dyndns

        # Host-specific
        beast
        self.nixosModules.overlay
        self.nixosModules.hmUnstable
      ];
    };
  };
}
