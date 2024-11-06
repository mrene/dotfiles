(_final: prev: {
  openrgb = prev.openrgb.overrideAttrs (old: {
  #   src = prev.fetchFromGitHub {
  #     owner = "CalcProgrammer1";
  #     repo = "OpenRGB";
  #     rev = "fa6a51654348f36e68a037051cd5c215e07d38e5";
  #     hash = "sha256-iTozmnPG870KYXzPP6POM8ryCKKdms40DKQ8EzN1C7g=";
  #   };
    patches = [./0001-sd_notify.patch];
    buildInputs = old.buildInputs ++ [prev.systemd];
  });
})
