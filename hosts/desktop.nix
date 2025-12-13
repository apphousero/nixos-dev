{
  lib,
  ...
}:

{
  networking.hostName = lib.mkDefault "desktop";
}
