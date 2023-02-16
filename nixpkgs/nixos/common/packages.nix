{ pkgs, inputs, ... }:

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
    lsof

    distrobox
    yq-go
    jq

    inputs.home-manager.packages.${system}.default
  ];

  programs.mtr.enable = true;

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };
}
