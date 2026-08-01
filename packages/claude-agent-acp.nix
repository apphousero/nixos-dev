{ pkgs }:

pkgs.buildNpmPackage {
  pname = "claude-agent-acp";
  version = "0.64.0";

  src = pkgs.fetchFromGitHub {
    owner = "agentclientprotocol";
    repo = "claude-agent-acp";
    rev = "e56f344691a56c07e5dae2ebeb6ad2a6416f8c9d";
    hash = "sha256-DBWsdGNbjkC1CzGwCpySOr07ruGkDdybfjkXI+3HXtA=";
  };

  npmDepsHash = "sha256-qx6IQzrndzPIcPhMZUOrZE8S3amfhoeMhg+gadZmHdk=";

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
