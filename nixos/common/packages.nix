{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wget
    curl
    direnv
    nix-direnv
    git
    zip
    unzip

    usbutils
    pciutils
    lm_sensors
    lshw
    file
    lsof

    yq-go
    jq

    btop
    man-pages
  ];

  programs.mtr.enable = true;

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };
}
