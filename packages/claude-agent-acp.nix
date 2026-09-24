{ pkgs }:

pkgs.buildNpmPackage {
  pname = "claude-agent-acp";
  version = "0.81.2";

  src = pkgs.fetchFromGitHub {
    owner = "agentclientprotocol";
    repo = "claude-agent-acp";
    rev = "5dbb453c63a89746627799b2b06b31ba01a1b674";
    hash = "sha256-5c4WTVtG628EwQq7WXDbFLu1u8wSAjlI7HbXsTH5xDg=";
  };

  npmDepsHash = "sha256-0Zjla0bbKrRKMT7SfBOKYmnbMw6zq27ddD2wxnbqg/Y=";

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
