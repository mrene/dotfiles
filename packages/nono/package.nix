{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  dbus,
  stdenv,
  darwin,
}:

rustPlatform.buildRustPackage rec {
  pname = "nono";
  version = "0.24.0";

  src = fetchFromGitHub {
    owner = "always-further";
    repo = "nono";
    rev = "v${version}";
    hash = "sha256-LhI5O85lwnSmMCoy5lbC9UCAKdMvRdtU2nt4WXyMPSk=";
  };

  cargoHash = "sha256-5H9TgMh4MhSvz7szbFPHdIkHk8RbpqSEw86ltn4Rr0E=";

  preCheck = ''
    mkdir -p /tmp/a /tmp/b
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    dbus
  ];

  meta = {
    description = "Kernel-enforced agent sandbox and agent security CLI and SDKs. Capability-based isolation with secure key management, atomic rollback, cryptographic immutable audit chain of provenance. Run your agents in a zero-trust environment";
    homepage = "https://github.com/always-further/nono";
    changelog = "https://github.com/always-further/nono/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "nono";
  };
}
