{ lib, stdenv }:

# From https://astojanov.github.io/blog/2011/09/26/pid-to-absolute-path.html
stdenv.mkDerivation {
  name = "pathfind";
  src = ./.;

  meta = with lib; {
    description = "Find the full path to a given pid";
    homepage = "https://astojanov.github.io/blog/2011/09/26/pid-to-absolute-path.html";
    platforms = platforms.darwin;
  };
}
