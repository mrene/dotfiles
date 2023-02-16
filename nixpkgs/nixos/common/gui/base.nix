{ config, common, pkgs, ... }:
{

  imports = [
    ../../../common/fonts.nix
  ];
  fonts.fontconfig = {
    enable = true; 
  };

  fonts.fontDir.enable = true;
  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  environment.systemPackages = with pkgs; [
    #pkgsUnstable.google-chrome
    (pkgsUnstable.google-chrome.override(old: { commandLineArgs = "--enable-features=WebUIDarkMode --force-dark-mode"; }))
    pkgsUnstable.chromium

    alacritty

    gnvim

    # The nixpkgs-unstable version fixes a bug around bad window dragging performance
    # https://github.com/wez/wezterm/issues/2530
    pkgs.pkgsUnstable.wezterm
    flameshot # Screenshot software
    simplescreenrecorder

    keybase
    keybase-gui

    xclip
    xsel
  ];

  programs._1password = {
    enable = true;
    package = pkgs.pkgsUnstable._1password;
  };

  programs._1password-gui = {
    enable = true;
    package = pkgs.pkgsUnstable._1password-gui;
    polkitPolicyOwners = [ "mrene "];
  };

  security.polkit.enable = true;

  programs.firefox = {
    enable = true;
    # TODO: Add extensions
  };

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
