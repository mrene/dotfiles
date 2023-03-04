(final: prev: {
  openrgb = (prev.openrgb.overrideAttrs (old: {
    src = prev.fetchFromGitLab {
      owner = "CalcProgrammer1";
      repo = "OpenRGB";
      rev = "ff8ac680ade8860acd522076e13910185f4f7bef";
      sha256 = "1wdzlp2jp5y1dfixhcr73zykrpsjk9kvdksljy6sn90vm8zlmrrk";
    };
    patches = [ ./0001-sd_notify.patch ];
    buildInputs = old.buildInputs ++ [ prev.systemd ];
  }));
})
