{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    neovim
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

    distrobox
    yq-go
    jq
  ];

  programs.mtr.enable = true;

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };
}
