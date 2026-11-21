{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-acp";
  version = "0.0.35";

  src = fetchFromGitHub {
    owner = "svkozak";
    repo = "pi-acp";
    rev = "41fb17a54f4599a0ca4723887cce0f40aaea325a";
    hash = "sha256-/5ga4YEi5GZ95ru+9gDpXp9iWVqmLeInIHddskO4uXg=";
  };

  npmDepsHash = "sha256-BtLtlL0zpoOzN094Wf9GZrpfQm4eVpcITzMxfEeMpKI=";

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
