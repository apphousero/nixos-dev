{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  networking.hostName = lib.mkDefault "dev";
}
