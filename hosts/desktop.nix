{
  lib,
  ...
}:

{
  imports = [
    ./iso.nix
  ];

  networking.hostName = lib.mkDefault "desktop";
}
