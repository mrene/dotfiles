{ lib, inputs, ... }:
{
  # Declare inputs used by this aspect for flake-file tracking
  flake-file.inputs.nixpkgs-pr-openthread.url = "github:mrene/nixpkgs?ref=openthread-border-router";

  flake.aspects.services-prs.nixos =
    { pkgs, ... }:
    {
      imports = [
        "${inputs.nixpkgs-pr-openthread}/nixos/modules/services/home-automation/openthread-border-router.nix"
      ];

      services.openthread-border-router.package =
        pkgs.callPackage
          "${inputs.nixpkgs-pr-openthread}/pkgs/by-name/op/openthread-border-router/package.nix"
          { };
    };
}
