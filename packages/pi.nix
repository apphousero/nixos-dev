{ pkgs }:

pkgs.buildNpmPackage {
  pname = "pi";
  version = "0.79.1";

  src = pkgs.fetchFromGitHub {
    owner = "earendil-works";
    repo = "pi-mono";
    rev = "dacb367e9e51a649eb16aee17ddece7ada896ee9";
    hash = "sha256-R1jDMeHtVReF1zWntedWHDWCay4l3dtPwZiridw9EAw=";
  };

  npmDepsHash = "sha256-ZWdfDDs+Hv+GWTmsNmpWNlUDBOMALw7H4lwo7CJHVCM=";

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
