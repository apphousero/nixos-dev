{
  lib,
  ...
}:

{
  imports = [
    ./iso.nix
  ];

  networking.hostName = lib.mkDefault "dev";
  system.stateVersion = "26.05";
}
