{ pkgs }:

let
  version = "0.81.1";
  piAiModelData = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@earendil-works/pi-ai/-/pi-ai-${version}.tgz";
    hash = "sha256-x53MD5DU370ZdNoz36P+OWZjGVpoM5sfVcEU2/ckDy8=";
  };
in
pkgs.buildNpmPackage {
  pname = "pi";
  inherit version;

  src = pkgs.fetchFromGitHub {
    owner = "earendil-works";
    repo = "pi-mono";
    rev = "20be4b18d4c57487f8993d2762bace129f0cf7c6";
    hash = "sha256-xo3uoR7HceOCL3wqoMcacOe8WXP1o7ReAXne5t6Hgao=";
  };

  npmDepsHash = "sha256-lzKQZbnITzgV9koucsMno6f61ubBLYUcwQEXtak1r1s=";

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
