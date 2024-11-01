{ pkgs, inputs, config, ... }: 

{
  imports = [
    "${inputs.nixpkgs-pr-openthread}/nixos/modules/services/home-automation/openthread-border-router.nix"
  ];

  services.openthread-border-router.package = pkgs.callPackage "${inputs.nixpkgs-pr-openthread}/pkgs/by-name/op/openthread-border-router/package.nix" {};
  nixpkgs.overlays = [
    (prev: super: {
      vscode = prev.callPackage "${inputs.nixpkgs-pr-vscode}/pkgs/applications/editors/vscode/vscode.nix" {};
    })
  ];
}

