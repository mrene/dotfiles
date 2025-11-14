# REFACTOR PLAN: This file will become:
#   - homelab.radio.enable
{pkgs, ...}:
let
  hardwarePackages = [
    pkgs.rtl-sdr
    pkgs.libbladeRF
    pkgs.uhd
    pkgs.soapysdr
  ];

  soapysdrPackages = [
    pkgs.soapyrtlsdr
    pkgs.soapybladerf
    pkgs.soapyuhd
  ];

  bladerf-fpga-firmware = pkgs.fetchurl {
    url = "https://www.nuand.com/fpga/v0.15.0/hostedx115.rbf";
    hash = "sha256-DVxsAzpDOGI+0+6t+q19I94g3P7YIDw654xOU0zew74=";
  };

  bladerf-search-dir = pkgs.runCommand "bladerf-search-dir" { } ''
    mkdir $out
    cp ${bladerf-fpga-firmware} $out/hostedx115.rbf
  '';
in
{
  hardware.rtl-sdr.enable = true;
  hardware.bladeRF.enable = true;
  services.udev.packages = hardwarePackages;
  environment.systemPackages = hardwarePackages;
  environment.variables = {
    BLADERF_SEARCH_DIR = bladerf-search-dir;
    SOAPY_SDR_PLUGIN_PATH = pkgs.lib.makeSearchPath pkgs.soapysdr.passthru.searchPath soapysdrPackages;
  };
}
