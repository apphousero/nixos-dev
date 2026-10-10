{ pkgs }:

pkgs.buildNpmPackage {
  pname = "claude-agent-acp";
  version = "0.88.0";

  src = pkgs.fetchFromGitHub {
    owner = "agentclientprotocol";
    repo = "claude-agent-acp";
    rev = "d43fec3fa3118e88ff8a8ed99b85d2a5f444e538";
    hash = "sha256-xLS5aCBOwFEaQgPiRhdUWV7rQFa7H0DQ1vFYtqZRERU=";
  };

  npmDepsHash = "sha256-4rJRg46lpT5ts4JRQEd7FsyA6OUO5zAU41Ctnv9CjZ4=";

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
