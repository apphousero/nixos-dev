{ pkgs, ... }:

let
  mm = pkgs.writeScriptBin "mm" (builtins.readFile ./sh/mm.sh);
in
{
  environment.systemPackages = [
    mm
  ];
}
