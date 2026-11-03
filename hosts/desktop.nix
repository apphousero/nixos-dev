{
  lib,
  ...
}:

{
  imports = [
    ./iso.nix
  ];

  networking.hostName = lib.mkDefault "desktop";
  system.stateVersion = "26.05";
}
