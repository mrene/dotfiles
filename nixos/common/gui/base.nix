{pkgs, ...}: {
  imports = [
    ../../../common/fonts.nix
  ];
  fonts.fontconfig = {
    enable = true;
  };

  fonts.fontDir.enable = true;
  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
  };

  environment.systemPackages = with pkgs;
    [
      chromium

      alacritty

      wezterm
      flameshot # Screenshot software
      simplescreenrecorder

      keybase

      xclip
      xsel
    ]
    ++ pkgs.lib.optionals pkgs.stdenv.isx86_64 [
      keybase-gui
      (google-chrome.override {commandLineArgs = "--enable-features=WebUIDarkMode --force-dark-mode";})
    ];

  programs._1password = {
    enable = true;
    package = pkgs._1password-cli;
  };

  programs._1password-gui = {
    enable = true;
    package = pkgs._1password-gui;
    polkitPolicyOwners = ["mrene "];
  };

  security.polkit.enable = true;

  programs.chromium = {
    enable = true;

    extensions = [
      "aomjjhallfgjeglblehebfpbcfeobpgk" # 1password
      "gighmmpiobklfepjocnamgkkbiglidom" # adblock
      "dcpbedhdekgkhigjgmlcbmcjoeaebbfm" # block and focus
      "eimadpbcbfnmbkopoojfekhnkhdbieeh" # dark reader
      "nakplnnackehceedgkgkokbgbmfghain" # fake spot
      "blkggjdmcfjdbmmmlfcpplkchpeaiiab" # omnivore
      "kbmfpngjjgdllneeigpgjifpgocmfgmb" # reddit enhancement suite
      "ennpfpdlaclocpomkiablnmbppdnlhoh" # rust search extension
      "okphadhbbjadcifjplhifajfacbkkbod" # sabnzbd connect
      "mnjggcdmjocbbbhaepdhchncahnbgone" # sponsorblock
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
    ];
  };
}
