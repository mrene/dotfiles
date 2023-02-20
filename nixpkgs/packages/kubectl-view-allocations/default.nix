{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, openssl
, breakpointHook
, perl
}:

rustPlatform.buildRustPackage rec {
  pname = "kubectl-view-allocations";
  version = "unstable-2023-02-13";

  src = fetchFromGitHub {
    owner = "davidB";
    repo = "kubectl-view-allocations";
    rev = "623b891b6bb71d7460a5efbd8fdb5970ea730c51";
    sha256 = "1cm4c16v12viqwf9jqb8np51n84m1l90v5nfzy7nvg7ydvq7da0g";
  };

  cargoHash = "sha256-Dreg8agLmDFb806REtK8cTsmQ7Iq5R4+Arlw3O4AV7w=";
  cargoPatches = [ ./add-cargo-lock.patch ./openssl-no-vendor.patch ];

  nativeBuildInputs = [ pkg-config breakpointHook  ];
  buildInputs = [ openssl ];

  meta = with lib; {
    description = "kubectl plugin to list allocations (cpu, memory, gpu,... X utilization, requested, limit, allocatable,...)";
    homepage = "https://github.com/davidB/kubectl-view-allocations";
    license = licenses.cc0;
    maintainers = with maintainers; [ ];
  };
}
