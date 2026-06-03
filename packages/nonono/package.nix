{
  writeShellApplication,
  bubblewrap,
  inputs,
  stdenv,
}:

let
  nono = inputs.llm-agents.packages.${stdenv.hostPlatform.system}.nono;
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
      sh -c 'mkdir -p /run/user/$(id -u) && nono run --allow-cwd -p ${profile} "$@"' -- "$@"
  '';

  meta = {
    description = "Sandboxed nono shell wrapper using bubblewrap";
    mainProgram = "nonono";
  };
}
