{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
, pkg-config
, openssl
, perl
, darwin ? null
}:

rustPlatform.buildRustPackage {
  pname = "kubectl-view-allocations";
  version = "0.16.3";

  src = fetchFromGitHub {
    owner = "davidB";
    repo = "kubectl-view-allocations";
    rev = "0.16.3";
    sha256 = "sha256-udi39j/K4Wsxva171i7mMUQ6Jb8Ny2IEHfldt3B8IoY=";
  };

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
    '';

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  #postPatch = ''
    #sed -i '/-Werror/d' Cargo.toml
  #'';

  nativeBuildInputs = [ pkg-config perl ];
  buildInputs = [ openssl ] ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [ Security ]);

  meta = with lib; {
    description = "kubectl plugin to list allocations (cpu, memory, gpu,... X utilization, requested, limit, allocatable,...)";
    homepage = "https://github.com/davidB/kubectl-view-allocations";
    license = licenses.cc0;
  };
}
