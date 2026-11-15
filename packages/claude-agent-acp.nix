{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
}:

buildNpmPackage (finalAttrs: {
  pname = "claude-agent-acp";
  version = "0.107.0";

  src = fetchFromGitHub {
    owner = "agentclientprotocol";
    repo = "claude-agent-acp";
    rev = "c5c120dba9c15bd88ea5d355fa3b77d1fc341392";
    hash = "sha256-egXaj0YPZtZE0rklOwjaZljsfbHH6mwJ17mERra8ouE=";
  };

  npmDepsHash = "sha256-AgCxbBMdqXHxnU/xIDNDoklEySgL2sTpHpWYkVOLZn8=";

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
