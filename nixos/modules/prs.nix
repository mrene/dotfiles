{ pkgs, inputs, config, ... }: 

{
  imports = [
    "${inputs.nixpkgs-pr-openthread}/nixos/modules/services/home-automation/openthread-border-router.nix"
    "${inputs.nixpkgs-pr-corefreq}/nixos/modules/programs/corefreq.nix"
  ];

  services.openthread-border-router.package = pkgs.callPackage "${inputs.nixpkgs-pr-openthread}pkgs/by-name/op/openthread-border-router/package.nix" {};
  programs.corefreq.package = config.boot.kernelPackages.callPackage "${inputs.nixpkgs-pr-corefreq}/pkgs/os-specific/linux/corefreq/default.nix" {};
}

