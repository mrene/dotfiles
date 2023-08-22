{ inputs, pkgs, ... }:

{
  imports = [
    # Include modules that aren't enabled-by-default
    inputs.nh.nixosModules.default
    inputs.minidsp.nixosModules.default
    inputs.nix-index-database.nixosModules.nix-index
  ];
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
