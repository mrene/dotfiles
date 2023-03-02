(final: prev: {
  openrgb = (prev.openrgb.overrideAttrs (old: {
    src = prev.fetchFromGitLab {
      owner = "CalcProgrammer1";
      repo = "OpenRGB";
      rev = "a4f86032a5ff11afcc12aad7985d1d066577b44e";
      sha256 = "1f3lyfl092pjkvvisvvx2zlzna7d7silkh4i0ylm313mc6fgslfl";
    };
    patches = [ ./0001-sd_notify.patch ];
    buildInputs = old.buildInputs ++ [ prev.systemd ];
  }));
})
