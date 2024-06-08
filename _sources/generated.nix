# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  homeassistant = {
    pname = "homeassistant";
    version = "2024.5.5";
    src = dockerTools.pullImage {
      imageName = "ghcr.io/home-assistant/home-assistant";
      imageDigest = "sha256:031d355a2e52e82fc33cd6854753fb19fc5d6a31af6f0f54c277d6f118ad993e";
      sha256 = "sha256-mh7mXvRa+4l0J3IsCiD1Uem75eFDAvppz4bl6ro29AE=";
      finalImageTag = "2024.5.5";
    };
  };
  hydroqc2mqtt = {
    pname = "hydroqc2mqtt";
    version = "1.3.0";
    src = dockerTools.pullImage {
      imageName = "registry.gitlab.com/hydroqc/hydroqc2mqtt";
      imageDigest = "sha256:cab62bffafb996746d4171714fc03d380796f9134d5d248ad04b872507ebe04b";
      sha256 = "sha256-ZkY9lMrqfnvUgAL8/UE86YFAG+tqsM6m6njVdCY066o=";
      finalImageTag = "1.3.0";
    };
  };
  python-matter-server = {
    pname = "python-matter-server";
    version = "6.0.1";
    src = dockerTools.pullImage {
      imageName = "ghcr.io/home-assistant-libs/python-matter-server";
      imageDigest = "sha256:adbf98bfae90d87540d040ccaeb4e94a7bd26cfc944ade7ac68cee43aeede7de";
      sha256 = "sha256-PU7RXJq9tMpgd45DnSW4WPFafqiMF/n2R7rBTxDXxuA=";
      finalImageTag = "6.0.1";
    };
  };
  smartir = {
    pname = "smartir";
    version = "1.17.9";
    src = fetchFromGitHub {
      owner = "smartHomeHub";
      repo = "SmartIR";
      rev = "1.17.9";
      fetchSubmodules = false;
      sha256 = "sha256-E6TM761cuaeQzlbjA+oZ+wt5HTJAfkF2J3i4P1Wbuic=";
    };
  };
}
