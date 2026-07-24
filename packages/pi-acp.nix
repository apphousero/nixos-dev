{ pkgs }:

pkgs.buildNpmPackage {
  pname = "pi-acp";
  version = "0.0.32";

  src = pkgs.fetchFromGitHub {
    owner = "svkozak";
    repo = "pi-acp";
    rev = "2f6e3c530819489bd09a84139b0b757df6895556";
    hash = "sha256-NksKacRpopm8lAaOG9tbHxJAcr4rlU0uL3dl/VkFbAA=";
  };

  npmDepsHash = "sha256-sRBrTwBwo8pcOy5WGDxHE86fvldgOtlppuvcbiB+7uc=";

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
