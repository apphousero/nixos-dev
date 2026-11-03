{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
  makeWrapper,
  tmux,
  gh,
}:

buildNpmPackage (finalAttrs: {
  pname = "aoaoe";
  version = "8.0.0";

  src = fetchFromGitHub {
    owner = "Talador12";
    repo = "agent-of-agent-of-empires";
    rev = "34926ae9684d2bfaa7ba3bcace417deee06d7b01";
    hash = "sha256-/UF8S21XC1kjp6TNjmjBDxau2lEQ11xNQR2HENFXPjk=";
  };

  npmDepsHash = "sha256-qwdC9I3L/ntxtwxP/BpIzjwBgEaudrv6SEC1xB8qZ3U=";

  nodejs = nodejs_22;

  npmBuildScript = "build";

  nativeBuildInputs = [ makeWrapper ];

  # aoaoe shells out to aoe/tmux/gh (and optionally claude/opencode).
  # tmux + gh are pinned here; aoe/claude/opencode resolve from the ambient
  # user PATH on useAoe hosts (aph-nixos home/modules/aoe.nix provides aoe).
  postInstall = ''
    for bin in aoaoe aoaoe-chat; do
      wrapProgram $out/bin/$bin \
        --prefix PATH : ${
          lib.makeBinPath [
            tmux
            gh
          ]
        }
    done
  '';

  meta = {
    description = "Autonomous supervisor for agent-of-empires sessions (OpenCode/Claude Code)";
    homepage = "https://github.com/Talador12/agent-of-agent-of-empires";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "aoaoe";
  };
})
