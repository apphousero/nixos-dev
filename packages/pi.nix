{ pkgs }:

let
  version = "0.81.0";
  piAiModelData = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@earendil-works/pi-ai/-/pi-ai-${version}.tgz";
    hash = "sha256-YuCrwc/6xDHQkcvI6I7u/LTEKLx40nAuxSvPXe/h/1o=";
  };
in
pkgs.buildNpmPackage {
  pname = "pi";
  inherit version;

  src = pkgs.fetchFromGitHub {
    owner = "earendil-works";
    repo = "pi-mono";
    rev = "9c480b6ad2c7419875a7a850fb4ad5f9232313b8";
    hash = "sha256-/TIYea6baa0vlz2G5wUv1aOknjEdo8zoo7eZI0Afjmk=";
  };

  npmDepsHash = "sha256-i0RwHPWBD06nh7FCM5F3R4kTOkH+7ulLFwIIDdH0vH0=";

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
    mkdir -p packages/ai/src/providers/data
    tar -xzf ${piAiModelData} -C packages/ai/src/providers/data \
      --strip-components=4 package/dist/providers/data

    substituteInPlace packages/ai/package.json \
      --replace-fail '"build": "npm run generate-models && npm run build:offline"' \
                      '"build": "npm run build:offline"'
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
