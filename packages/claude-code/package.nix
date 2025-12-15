{
  lib,
  stdenv,
  buildNpmPackage,
  fetchzip,
  nodejs_20,
  bubblewrap,
  socat,
}:

let
  runtimeInputs = [ socat ] ++ lib.optional stdenv.isLinux bubblewrap;
in

buildNpmPackage rec {
  pname = "claude-code";
  version = "2.0.71";

  nodejs = nodejs_20; # required for sandboxed Nix builds on Darwin

  src = fetchzip {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
    hash = "sha256-krbaIy1KfmbwroQRZpGR6bOYNc2l/GZKjhavmiwVCms=";
  };

  npmDepsHash = "sha256-VzUCEI4fl7PUV/+BBxiUClpFxqC2Gb98vRLsllZNwWo=";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  AUTHORIZED = "1";

  # `claude-code` tries to auto-update by default, this disables that functionality.
  # https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview#environment-variables
  # The DEV=true env var causes claude to crash with `TypeError: window.WebSocket is not a constructor`
  postInstall = ''
    wrapProgram $out/bin/claude \
      --prefix PATH ":" "${lib.makeBinPath runtimeInputs}" \
      --set DISABLE_AUTOUPDATER 1 \
      --unset DEV
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster";
    homepage = "https://github.com/anthropics/claude-code";
    downloadPage = "https://www.npmjs.com/package/@anthropic-ai/claude-code";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [
      malo
      markus1189
      omarjatoi
    ];
    mainProgram = "claude";
  };
}
