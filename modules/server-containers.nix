{
  lib,
  ...
}:
{
  imports = [
    ./server.nix
  ];
  # Podman configuration
  virtualisation.containers.enable = lib.mkDefault true;
  virtualisation.podman = {
    enable = lib.mkDefault true;
    dockerCompat = lib.mkDefault true;
    defaultNetwork.settings.dns_enabled = lib.mkDefault true;
  };

}
