{
  lib,
  ...
}:
{
  wsl = {
    enable = lib.mkDefault true;
    defaultUser = lib.mkDefault "andrei";
    docker-desktop = {
      enable = lib.mkDefault true;
    };
  };

  services.vscode-server.enable = lib.mkDefault true;

  # Networking optimizations for WSL
  networking = {
    # Use WSL's networking instead of systemd-networkd
    dhcpcd.enable = false;
    useNetworkd = false;
    # Disable unnecessary network services
    firewall.enable = false; # Windows firewall handles this
  };

  # Environment optimizations
  environment = {
    # WSL-specific environment variables (BROWSER and Windows interop aliases
    # come from modules/wsl.nix, which derives the paths from winMount/winUser)
    variables = {
      WSLENV = "USERPROFILE/p:APPDATA/p";
    };
  };
}
