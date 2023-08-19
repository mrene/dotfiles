(_final: prev: {
  openrgb = prev.openrgb.overrideAttrs (old: {
    src = prev.fetchFromGitLab {
      owner = "CalcProgrammer1";
      repo = "OpenRGB";
      rev = "baf5d30b27fe5125d17a0df57838eac4234ff01b"; #pin
      sha256 = "0nw1adnyha4rdd37pgl9izhyg8pcmmd4h00cgv3pmmhc3kg5ryha";
    };
    patches = [ ./0001-sd_notify.patch ];
    buildInputs = old.buildInputs ++ [ prev.systemd ];
  });
})
