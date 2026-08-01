{ pkgs }:

pkgs.buildNpmPackage {
  pname = "pi-acp";
  version = "0.0.33";

  src = pkgs.fetchFromGitHub {
    owner = "svkozak";
    repo = "pi-acp";
    rev = "1bfcb394088ed879db8fd936b570bb626017f878";
    hash = "sha256-fENOOdooi4XbIDjcr02q8qzUCzdo2IW/Bca43SawZ44=";
  };

  npmDepsHash = "sha256-/fX79XucKojL/6gZbK5eizEfrXso8rlTgiHfJffmDuY=";

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
