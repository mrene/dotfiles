(final: prev: {
  openrgb = (prev.openrgb.overrideAttrs (old: {
      src = prev.fetchFromGitLab {
        owner = "CalcProgrammer1";
        repo = "OpenRGB";
        rev = "ddb7b141a39319d23aac143a9f00b2a934be8820";
        sha256 = "1vfzb4n9ih7hvxyllhyh8inzfwdvk25y43f96q37lffiwhik3y36";
      };
      patches = [ ./0001-sd_notify.patch ];
      buildInputs = old.buildInputs ++ [ prev.systemd ];
    }));
})
