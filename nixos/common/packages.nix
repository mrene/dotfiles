{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    # Include modules that aren't enabled-by-default
    inputs.minidsp.nixosModules.default
    inputs.nix-index-database.nixosModules.nix-index
  ];

  programs.command-not-found.enable = false; # conflicts with nix-index
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
    unixtools.xxd

    yq-go
    jq

    btop
    man-pages
    wireshark
    sysstat
    dstat
    bat
    eza
    fd
    tmux-xpanes
    ipset
    iptables
  ];

  programs.mtr.enable = true;

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };
}
