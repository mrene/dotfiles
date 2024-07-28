{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, systemdLibs
, avahi
, dbus
, protobuf
, jsoncpp
, boost
}:

stdenv.mkDerivation {
  pname = "ot-br-posix";
  version = "unstable-2024-07-26";

  src = fetchFromGitHub {
    owner = "openthread";
    repo = "ot-br-posix";
    rev = "6f3dfdc7a7856086831a4e234812591f2a7cd793";
    hash = "sha256-cp/CJB8ykQvbfSd/qjpGjIQ7ePRVSM+97YRacqUzw/c=";
    fetchSubmodules = true;
  };

  patches = [
    ./dont-install-systemd-units.patch
    ./dont-use-boost-static-libs.patch
  ];

  nativeBuildInputs = [
    pkg-config
    cmake
  ];

  buildInputs =[
    avahi
    systemdLibs
    #dbus
    protobuf
    jsoncpp
    boost
  ];

  cmakeFlags = [
    # These defaults are from "examples/platforms/raspbian/default"
    (lib.cmakeBool "OTBR_REST" true)

    # Needs npm to build the frontend code, that's another day's project
    (lib.cmakeBool "OTBR_WEB" false)
    (lib.cmakeBool "OTBR_NAT64" true)
    (lib.cmakeBool "OTBR_DNS64" false)
    (lib.cmakeBool "OTBR_BACKBONE_ROUTER" true)
    (lib.cmakeBool "OTBR_BORDER_ROUTING" true)
    (lib.cmakeBool "OTBR_DBUS" false)
    (lib.cmakeBool "OTBR_TREL" true)


    # From _otbr
    (lib.cmakeBool "OTBR_DNSSD_DISCOVERY_PROXY" true)
    (lib.cmakeBool "OTBR_SRP_DISCOVERY_PROXY" true)

    # Required by protobuf
    (lib.cmakeFeature "CMAKE_CXX_STANDARD" "17")
  ];

  meta = with lib; {
    description = "A Thread border router for POSIX-based platforms";
    homepage = "https://github.com/openthread/ot-br-posix";
    license = licenses.bsd3;
    maintainers = with maintainers; [ mrene ];
    mainProgram = "ot-ctl";
    platforms = platforms.linux;
  };
}
