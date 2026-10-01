{ pkgs }:

pkgs.buildNpmPackage {
  pname = "pi-acp";
  version = "0.0.34";

  src = pkgs.fetchFromGitHub {
    owner = "svkozak";
    repo = "pi-acp";
    rev = "b0581c9c1d675e634234674484247008b03d69b4";
    hash = "sha256-QRwxOtTZOY+Np3PkAoy2o2PrUzEqjItM/372sCPlSMo=";
  };

  npmDepsHash = "sha256-BvLNtFfp1cMVjzWcMRSdhTqiJrTfbFoUbWkkPW9200o=";

  nodejs = pkgs.nodejs_22;

  npmBuildScript = "build";

  dontNpmInstall = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/pi-acp
    cp -r . $out/lib/node_modules/pi-acp/

    mkdir -p $out/bin
    makeWrapper ${pkgs.nodejs_22}/bin/node $out/bin/pi-acp \
      --add-flags "$out/lib/node_modules/pi-acp/dist/index.js" \
      --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.nodejs_22 ]}

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "ACP (Agent Client Protocol) adapter for pi coding agent";
    homepage = "https://github.com/svkozak/pi-acp";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
