{ pkgs }:

{
  environment.systemPackages = with pkgs; [
    neovim
    wget
    curl
    direnv
    nix-direnv
    git

    usbutils
    pciutils
    lm_sensors
    lshw
    file

    distrobox
  ];

  programs.mtr.enable = true;
  
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };
}