{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
}:

buildNpmPackage (finalAttrs: {
  pname = "claude-agent-acp";
  version = "0.100.0";

  src = fetchFromGitHub {
    owner = "agentclientprotocol";
    repo = "claude-agent-acp";
    rev = "981bf9a28ac3afef26e7877a2a638814c34f1679";
    hash = "sha256-D0CWA9x/K6b4yMT90tmYuI8UQed2ZC0FfMtPClzVrck=";
  };

  npmDepsHash = "sha256-7/RAN3CPe/Fw+ovL6emXH8pTJ5r2q2w8FbgwVNqWekw=";

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
