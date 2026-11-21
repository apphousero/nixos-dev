{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
}:

buildNpmPackage (finalAttrs: {
  pname = "claude-agent-acp";
  version = "0.109.1";

  src = fetchFromGitHub {
    owner = "agentclientprotocol";
    repo = "claude-agent-acp";
    rev = "4af4581ad510a85d5cdfa3b9100412479e1cfef4";
    hash = "sha256-1nX95rqpzbbPk5OFcpVJLfewemIX3GW7BhYXP9oZboE=";
  };

  npmDepsHash = "sha256-yz+zSb0XRVowNbRU9qvNsi0Wsc+cTZ2Iqlg+vqCuA2c=";

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
