{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, openssl
}:

rustPlatform.buildRustPackage rec {
  pname = "kubectl-view-allocations";
  version = "0.15.1";

  src = fetchFromGitHub {
    owner = "davidB";
    repo = "kubectl-view-allocations";
    rev = version;
    hash = "sha256-GqhaTxPdJH0kvsqxvRAzS/Yt3wmJ3ahzJOIiuE9VJxE=";
  };

  cargoHash = "sha256-ZJ4yPo17+hLV+nXNEIVy86PvGxcrKc+ctJKtCj8GO8A=";
  cargoPatches = [ ./add-cargo-lock.patch ];
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  meta = with lib; {
    description = "kubectl plugin to list allocations (cpu, memory, gpu,... X utilization, requested, limit, allocatable,...)";
    homepage = "https://github.com/davidB/kubectl-view-allocations";
    license = licenses.cc0;
    maintainers = with maintainers; [ ];
  };
}
