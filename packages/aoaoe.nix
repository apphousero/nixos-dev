{ pkgs }:

pkgs.buildNpmPackage {
  pname = "aoaoe";
  version = "8.0.0";

  src = pkgs.fetchFromGitHub {
    owner = "Talador12";
    repo = "agent-of-agent-of-empires";
    rev = "34926ae9684d2bfaa7ba3bcace417deee06d7b01";
    hash = "sha256-/UF8S21XC1kjp6TNjmjBDxau2lEQ11xNQR2HENFXPjk=";
  };

  npmDepsHash = "sha256-qwdC9I3L/ntxtwxP/BpIzjwBgEaudrv6SEC1xB8qZ3U=";

  nodejs = pkgs.nodejs_22;

  npmBuildScript = "build";

  dontNpmInstall = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/aoaoe
    cp -r . $out/lib/node_modules/aoaoe/

    mkdir -p $out/bin
    # aoaoe shells out to aoe/tmux/gh (and optionally claude/opencode).
    # tmux + gh are pinned here; aoe/claude/opencode resolve from the ambient
    # user PATH on useAoe hosts (aph-nixos home/modules/aoe.nix provides aoe).
    makeWrapper ${pkgs.nodejs_22}/bin/node $out/bin/aoaoe \
      --add-flags "$out/lib/node_modules/aoaoe/dist/index.js" \
      --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.nodejs_22 pkgs.tmux pkgs.gh ]}

    makeWrapper ${pkgs.nodejs_22}/bin/node $out/bin/aoaoe-chat \
      --add-flags "$out/lib/node_modules/aoaoe/dist/chat.js" \
      --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.nodejs_22 pkgs.tmux pkgs.gh ]}

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Autonomous supervisor for agent-of-empires sessions (OpenCode/Claude Code)";
    homepage = "https://github.com/Talador12/agent-of-agent-of-empires";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
