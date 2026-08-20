{ pkgs }:

pkgs.buildNpmPackage {
  pname = "claude-agent-acp";
  version = "0.70.0";

  src = pkgs.fetchFromGitHub {
    owner = "agentclientprotocol";
    repo = "claude-agent-acp";
    rev = "d0aafb1ca26427285ffaeac8d8a4452fff28e9c3";
    hash = "sha256-g7yg+rg1OzIg+8drikA8JoraOzrF/F4kD4dJfXAqlWY=";
  };

  npmDepsHash = "sha256-cgRQM/G/zGoanY73E6pQxpCN6IyIidGh8nR3KMITdfY=";

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
