{ pkgs }:

pkgs.buildNpmPackage {
  pname = "pi";
  version = "0.80.3";

  src = pkgs.fetchFromGitHub {
    owner = "earendil-works";
    repo = "pi-mono";
    rev = "a23abe4a695df8b69b613f73e9fdda2a8af894d4";
    hash = "sha256-wQTrWKsb2HCGwzSAFEk8NWSDpqxSY/lv1/R6ghcmbaA=";
  };

  npmDepsHash = "sha256-geh8LH88OZybFXkR/jDeTdew6TNMdFM6jhCSYKn//dU=";

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
      --replace-fail '"build": "npm run generate-models && npm run generate-image-models && tsgo -p tsconfig.build.json"' \
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
    homepage = "https://github.com/earendil-works/pi-mono";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
