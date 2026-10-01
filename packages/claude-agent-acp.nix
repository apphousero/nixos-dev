{ pkgs }:

pkgs.buildNpmPackage {
  pname = "claude-agent-acp";
  version = "0.85.0";

  src = pkgs.fetchFromGitHub {
    owner = "agentclientprotocol";
    repo = "claude-agent-acp";
    rev = "c84845272fe3c55c1f97759f00ee48a1356fccae";
    hash = "sha256-jlGKjfxn5LGnSireMOwu0xuW6rJicGHsTDfCrjh8FnY=";
  };

  npmDepsHash = "sha256-Gvarc8VzL0OLMNrGC7uAMX3UyK7c+qtkZd3BBHBsP4c=";

  nodejs = pkgs.nodejs_22;

  npmBuildScript = "build";

  dontNpmInstall = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/claude-agent-acp
    cp -r . $out/lib/node_modules/claude-agent-acp/

    mkdir -p $out/bin
    makeWrapper ${pkgs.nodejs_22}/bin/node $out/bin/claude-agent-acp \
      --add-flags "$out/lib/node_modules/claude-agent-acp/dist/index.js" \
      --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.nodejs_22 ]}

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "An ACP-compatible coding agent powered by the Claude Agent SDK (TypeScript)";
    homepage = "https://github.com/agentclientprotocol/claude-agent-acp";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
