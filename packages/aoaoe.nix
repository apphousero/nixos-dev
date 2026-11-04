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
  version = "7.5.0";

  src = fetchFromGitHub {
    owner = "Talador12";
    repo = "agent-of-agent-of-empires";
    rev = "31b61380325950f00a2613838a56d4c60a88394f";
    hash = "sha256-jqvQcS8hhXcPidipOAgfVRN3fdqjOukp966XOdGv5Pg=";
  };

  npmDepsHash = "sha256-ZP4xTjcB/o/rJCWOQuLt3hgGk9cFFGaDOP9SBqL/1Z8=";

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
