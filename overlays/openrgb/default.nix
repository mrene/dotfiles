(final: prev: {
  openrgb = (prev.openrgb.overrideAttrs (old: {
    src = prev.fetchFromGitLab {
      owner = "CalcProgrammer1";
      repo = "OpenRGB";
      rev = "de43a02a1b19b28f88e6e5cd0cdb58a953b630f5";
      sha256 = "1asvhz7532hpg16vgf6p3kyj0r27a0j5kjn9f5klf7jg26jmr4vn";
    };
    patches = [ ./0001-sd_notify.patch ];
    buildInputs = old.buildInputs ++ [ prev.systemd ];
  }));
})
