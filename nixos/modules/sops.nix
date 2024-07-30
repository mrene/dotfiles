{ lib, config, pkgs, inputs,  ... }:

let
  cfg = config.homelab.sops;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  options.homelab.sops = {
    enable = lib.mkEnableOption "Enable homelab sops-nix configuration";
  };

  config = lib.mkIf cfg.enable {
    sops = {
      # Deploy this file out-of-band using the latest secrets
      defaultSopsFile = lib.mkDefault "/var/lib/secrets/sops.yaml";
      defaultSopsFormat = lib.mkDefault "yaml";
      validateSopsFiles = lib.mkDefault false;

      # Use the ed25519 host key. Some systems (e.g. rpis) won't have RSA keys
      # due to the limited amount of CPU available to generate them.
      age.sshKeyPaths = lib.mkDefault [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
  };
}
