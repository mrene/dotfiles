{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, openssl
, stdenv
, darwin
, perl
, breakpointHook
}:

rustPlatform.buildRustPackage rec {
  pname = "rtx";
  version = "1.18.1";

  src = fetchFromGitHub {
    owner = "jdxcode";
    repo = "rtx";
    rev = "v${version}";
    hash = "sha256-+cLma124CngqNvOb9PF1INQ25C0cuVTab4OmviphTtM=";
  };

  cargoHash = "sha256-KLQCcus+hhDNzL8LL2nacpKiz5LaUilsReR22Jqp6FE=";

  # Tests fail with permission errors trying to overwrite source files
  doCheck = false;

  nativeBuildInputs = [
    pkg-config
    perl
    breakpointHook
  ];

  buildInputs = [
    openssl
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.CoreFoundation
    darwin.apple_sdk.frameworks.Security
  ];

  meta = with lib; {
    description = "Runtime Executor (asdf rust clone)";
    homepage = "https://github.com/jdxcode/rtx";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
