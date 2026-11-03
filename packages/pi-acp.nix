{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-acp";
  version = "0.0.34";

  src = fetchFromGitHub {
    owner = "svkozak";
    repo = "pi-acp";
    rev = "b0581c9c1d675e634234674484247008b03d69b4";
    hash = "sha256-QRwxOtTZOY+Np3PkAoy2o2PrUzEqjItM/372sCPlSMo=";
  };

  npmDepsHash = "sha256-BvLNtFfp1cMVjzWcMRSdhTqiJrTfbFoUbWkkPW9200o=";

  nodejs = nodejs_22;

  npmBuildScript = "build";

  meta = {
    description = "ACP (Agent Client Protocol) adapter for pi coding agent";
    homepage = "https://github.com/svkozak/pi-acp";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "pi-acp";
  };
})
