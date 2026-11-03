{
  modulesPath,
  ...
}:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  boot.zfs.forceImportRoot = false;

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
  };
}
