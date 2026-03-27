{
  lib,
  writeShellApplication,
  bubblewrap,
  callPackage,
}:

let
  nono = callPackage ../nono/package.nix { };
  profile = ./nono-profile.json;
in

writeShellApplication {
  name = "nonono";

  runtimeInputs = [
    bubblewrap
    nono
  ];

  excludeShellChecks = [ "SC2016" ];

  text = ''
    exec bwrap \
      --dev-bind / / \
      --tmpfs /run \
      --ro-bind /run/current-system /run/current-system \
      --ro-bind /run/systemd/resolve /run/systemd/resolve -- \
      sh -c 'mkdir -p /run/user/$(id -u) && nono shell --allow-cwd -p ${profile} "$@"' -- "$@"
  '';

  meta = {
    description = "Sandboxed nono shell wrapper using bubblewrap";
    mainProgram = "nonono";
  };
}
