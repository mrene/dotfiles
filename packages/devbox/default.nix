{
  lib,
  buildGo121Module,
  fetchFromGitHub,
  ...
}:
buildGo121Module rec {
  pname = "devbox";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "jetpack-io";
    repo = "devbox";
    rev = version;
    hash = "sha256-G3ThYV2rmczSyFNnshyHvKOTt4Rv7m7bryJSsT/KG+Q=";
  };

  vendorHash = "sha256-fDh+6aBrHUqioNbgufFiD5c4i8SGAYrUuFXgTVmhrRE=";

  ldflags = [
    "-s"
    "-w"
    "-X=go.jetpack.io/devbox/internal/build.Version=${version}"
    "-X=go.jetpack.io/devbox/internal/build.Commit=${src.rev}"
    "-X=go.jetpack.io/devbox/internal/build.CommitDate=1970-01-01T00:00:00Z"
    #"-X=go.jetpack.io/devbox/internal/build.SentryDSN=${envSentryDsn}"
    #"-X=go.jetpack.io/devbox/internal/build.TelemetryKey=${envTelemetryKey}"
  ];

  doCheck = false;

  env = {
    CGO_CFLAGS = "-Wno-undef-prefix";
  };

  meta = with lib; {
    description = "Instant, easy, and predictable development environments";
    homepage = "https://github.com/jetpack-io/devbox";
    license = licenses.asl20;
    maintainers = with maintainers; [];
    mainProgram = "devbox";
  };
}
