{
  lib,
  ...
}:
{
  imports = [
    ./development.nix
  ];

  # Get latest from here https://github.com/nix-community/NixOS-WSL/releases
  system.stateVersion = "25.05";

  wsl = {
    enable = lib.mkDefault true;
    defaultUser = lib.mkDefault "andrei";
    docker-desktop = {
      enable = lib.mkDefault true;
    };
    wslConf = {
      interop.appendWindowsPath = lib.mkDefault false;
      network.generateHosts = lib.mkDefault false;
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
    # WSL-specific environment variables
    variables = {
      # Use Windows browser for opening URLs
      BROWSER = "/mnt/c/Windows/System32/cmd.exe /c start";
      # WSL-specific paths
      WSLENV = "USERPROFILE/p:APPDATA/p";
    };

    # Shell aliases for WSL convenience
    shellAliases = {
      # Quick access to Windows directories
      cdwin = "cd /mnt/c/Users/$USER";
      # Windows interop
      explorer = "explorer.exe";
      notepad = "notepad.exe";
      cmd = "cmd.exe";
      powershell = "powershell.exe";
    };
  };
}
