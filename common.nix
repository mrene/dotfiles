_: {
  flake.common = {
    sshKeys = [
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBMDK9LCwU62BIcyn73TcaQlMqr12GgYnHYcw5dbDDNmYnpp2n/jfDQ5hEkXd945dcngW6yb7cmgsa8Sx9T1Uuo4= secretive@mbp2021"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAeSvwegmfet4Rw8OBFEVUfx+5WmVcYR4/n20QSh4tAs mrene@beast"
    ];

    builderKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGYXed3Lzz4fWZmjt7VHvWDldk1VNlcSDokM7ZcguTFh root@beast"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHeCYLyIA2TgH8tE5i8pyCV2HvU/iepBx/ch6gh8IwbC nas-builder"
    ];

    sudoSshKeys = [
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBMpIqFppmJu+oXgUA9t+KK7xY07FAy1ZpMQ2xe03fhnaufg8UAT35cTMvf5KpCDRiCRsdv37tXpmfmgV27eiFWA= Remote-sudo@secretive.Mathieu’s-MacBook-Pro.local"
    ];
  };
}
