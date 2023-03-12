{ lib, config, pkgs, common, inputs, ... }:

{

  # Reduce supported filesystems to prevent compiling things we don't need
  boot.supportedFilesystems = lib.mkForce [ "ext4" "vfat" ];

  # Only generate an ed5519 key, because rsa keygen takes minutes
  services.openssh.hostKeys = lib.mkForce [{
    path = "/etc/ssh/ssh_host_ed25519_key";
    type = "ed25519";
  }];


}
