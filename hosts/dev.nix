{
  lib,
  ...
}:

{
  networking.hostName = lib.mkDefault "dev";
}
