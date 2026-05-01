{ pkgs }:

pkgs.buildNpmPackage {
  pname = "pi";
  version = "0.71.0";

  src = pkgs.fetchFromGitHub {
    owner = "badlogic";
    repo = "pi-mono";
    rev = "f4efeb2ba5a4a1f79d51f729da008d8fcb7cf512";
    hash = "sha256-SDfA+dKW7dCUMp0sjcB7B3gnX+0hcoNROREUH+aSTMo=";
  };

  npmDepsHash = "sha256-3W2YMBaUe704Y78Zw13o9dC9lwwHri+4OwFwCpq2drA=";

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
