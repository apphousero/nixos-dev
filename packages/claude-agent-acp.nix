{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
}:

buildNpmPackage (finalAttrs: {
  pname = "claude-agent-acp";
  version = "0.109.0";

  src = fetchFromGitHub {
    owner = "agentclientprotocol";
    repo = "claude-agent-acp";
    rev = "9f1ca6eb9c65c2f5d1bbf48335af42947ddb74d6";
    hash = "sha256-I2m+q06rB5hxi2J1Ai5mdcbZYD3p0LQ4/KAruk0jjQs=";
  };

  npmDepsHash = "sha256-qSKBpAYu2/2B5uBnkS+yqdqyUDfHsbIyTgk824GPcH4=";

  nodejs = nodejs_22;

  npmBuildScript = "build";

  meta = {
    description = "An ACP-compatible coding agent powered by the Claude Agent SDK (TypeScript)";
    homepage = "https://github.com/agentclientprotocol/claude-agent-acp";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "claude-agent-acp";
  };
})
