{
  config,
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs.llm-agents = {
    url = "github:numtide/llm-agents.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.aspects.dev-ai.homeManager =
    { pkgs, ... }:
    lib.optionalAttrs (inputs ? llm-agents) {
      programs.claude-code = {
        enable = true;
        package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
      };
    };
}
