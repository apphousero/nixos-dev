{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
}:

buildNpmPackage (finalAttrs: {
  pname = "claude-agent-acp";
  version = "0.106.0";

  src = fetchFromGitHub {
    owner = "agentclientprotocol";
    repo = "claude-agent-acp";
    rev = "51f514d73c8bfd786979c84adb7a8517dbc22695";
    hash = "sha256-sVNJoC9KgMeFkSlW6txklN0I5+2LrDTif3lDhcUzMBI=";
  };

  npmDepsHash = "sha256-lyU8Qu4A1bzDQOMKyjHrEbpfwgU0OCz5CeapHMSYrr4=";

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
