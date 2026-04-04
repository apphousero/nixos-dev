{ config }:
let
  packages =
    (if config ? environment then config.environment.systemPackages or [ ] else [ ])
    ++ (if config ? home then config.home.packages or [ ] else [ ]);
  hasPackage = pkg: builtins.any (p: p.pname or p.name or "" == pkg) packages;
in
{
  inherit hasPackage;
  hasDotnetSdk = hasPackage "dotnet" || hasPackage "dotnet-sdk" || hasPackage "dotnet-sdk-wrapped";
  hasNodejs = hasPackage "nodejs";
  hasPython = hasPackage "python3";
  hasGo = hasPackage "go";
  hasJava = hasPackage "openjdk" || hasPackage "jdk";
}
