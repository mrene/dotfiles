{ lib, ... }:
{
  flake.aspects.services-sops.nixos = _: {
    # Note: sops-nix module is imported by clan-core for clan machines.
    # For non-clan machines, it needs to be imported in the host configuration.
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
