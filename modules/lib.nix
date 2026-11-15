{ packages }:
let
  hasPackage = pkg: builtins.any (p: p.pname or p.name or "" == pkg) packages;
in
{
  inherit hasPackage;
  hasNodejs = hasPackage "nodejs";
  hasPython = hasPackage "python3";
  hasGo = hasPackage "go";
  hasJava = hasPackage "openjdk" || hasPackage "jdk";
}
