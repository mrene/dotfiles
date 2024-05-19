# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  homeassistant = {
    pname = "homeassistant";
    version = "2024.5.4";
    src = dockerTools.pullImage {
      imageName = "ghcr.io/home-assistant/home-assistant";
      imageDigest = "sha256:6f5eeb8360d9d58ff096c7259366993b4b01ebe11251c2b83c9329daad441b00";
      sha256 = "sha256-OSaqw8yOhiVacQOiohhO48guZdfw1yEI4f/+Eil2CjY=";
      finalImageTag = "2024.5.4";
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
    version = "6.0.0";
    src = dockerTools.pullImage {
      imageName = "ghcr.io/home-assistant-libs/python-matter-server";
      imageDigest = "sha256:1971cbc3b1d850beda8043b0a870c3d1b35ba858f1b6af670bdbc2aa62e092eb";
      sha256 = "sha256-2snqZR4b+axaAC++Y5KWYhoDpf12Le8wO4K0MHRl7aM=";
      finalImageTag = "6.0.0";
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
