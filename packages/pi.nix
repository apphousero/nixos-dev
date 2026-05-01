{ pkgs }:

pkgs.buildNpmPackage {
  pname = "pi";
  version = "0.71.1";

  src = pkgs.fetchFromGitHub {
    owner = "badlogic";
    repo = "pi-mono";
    rev = "80a439055d467001279d711c9b5d737df35113e0";
    hash = "sha256-FOR0py2stVmRwdeMr7Oh6xwYrlcyUWE9f0OEKF2rO5g=";
  };

  npmDepsHash = "sha256-irLlmq/to4x0GnNhSFVmfiuaiPx3B9l+PhlVeJSfhpU=";

  nodejs = pkgs.nodejs_22;

  nativeBuildInputs = with pkgs; [
    pkg-config
    python3
    makeWrapper
  ];

  buildInputs = with pkgs; [
    cairo
    pango
    libjpeg
    giflib
    librsvg
    pixman
  ];

  npmBuildScript = "build";

  preBuild = ''
    substituteInPlace packages/ai/package.json \
      --replace-fail '"build": "npm run generate-models && tsgo -p tsconfig.build.json"' \
                      '"build": "tsgo -p tsconfig.build.json"'
  '';

  dontNpmInstall = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/pi-monorepo
    cp -r . $out/lib/node_modules/pi-monorepo/
    rm -rf $out/lib/node_modules/pi-monorepo/node_modules/.bin

    mkdir -p $out/bin
    makeWrapper ${pkgs.nodejs_22}/bin/node $out/bin/pi \
      --add-flags "$out/lib/node_modules/pi-monorepo/packages/coding-agent/dist/cli.js" \
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.ripgrep
          pkgs.fd
          pkgs.git
        ]
      }

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "An AI coding agent that can read/write files, execute commands, and edit code";
    homepage = "https://github.com/badlogic/pi-mono";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
