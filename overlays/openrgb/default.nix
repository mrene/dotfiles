(_final: prev: {
  openrgb = prev.openrgb.overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "CalcProgrammer1";
      repo = "OpenRGB";
      rev = "6c279ea830e5442fc409a958b979fb8949073b2e";
      hash = "sha256-Il3EpVsM5FjzpH5ayplz1ezCeV+cY0LPF/66+US8RGY=";
    };
    patches = [ ./0001-sd_notify.patch ];
    buildInputs = old.buildInputs ++ [ prev.systemd ];
  });
})
