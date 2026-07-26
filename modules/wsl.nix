{
  lib,
  config,
  ...
}:
let
  winUser = config.nixos-dev.wsl.windowsUsername;
  winMount = config.nixos-dev.wsl.windowsMount;

  winRoot = "${winMount}/Windows";
  system32 = "${winRoot}/System32";
  vscodeBin = "${winMount}/Users/${winUser}/AppData/Local/Programs/Microsoft VS Code/bin";
in
{
  imports = [
    ./development.nix
  ];

  options.nixos-dev.wsl = {
    defaultUser = lib.mkOption {
      type = lib.types.str;
      default = "andrei";
      example = "john";
      description = ''
        Linux-side username created inside WSL and used as
        {option}`wsl.defaultUser`.
      '';
    };

    windowsUsername = lib.mkOption {
      type = lib.types.str;
      default = config.wsl.defaultUser;
      defaultText = lib.literalExpression "config.wsl.defaultUser";
      example = "john";
      description = ''
        Windows-side username used to build paths to per-user Windows
        executables (VS Code, the Windows home directory, ...) reachable from
        WSL. Defaults to {option}`wsl.defaultUser`; set this in a downstream
        flake when the Windows account name differs from the Linux user.
      '';
    };

    windowsMount = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/c";
      example = "/mnt/c";
      description = "Mount point of the Windows system (C:) drive inside WSL.";
    };
  };

  config = {
    # Get latest from here https://github.com/nix-community/NixOS-WSL/releases
    system.stateVersion = "26.05";

    wsl = {
      enable = lib.mkDefault true;
      defaultUser = lib.mkDefault config.nixos-dev.wsl.defaultUser;
      docker-desktop = {
        enable = lib.mkDefault true;
      };
      wslConf = {
        interop.appendWindowsPath = lib.mkDefault false;
        network.generateHosts = lib.mkDefault false;
      };
      interop.register = lib.mkDefault true;
    };

    services.vscode-server.enable = lib.mkDefault true;

    programs.nix-ld.enable = lib.mkDefault true;

    # Networking optimizations for WSL
    networking = {
      hostName = lib.mkDefault "nixos";
      # Use WSL's networking instead of systemd-networkd
      dhcpcd.enable = false;
      useNetworkd = false;
      # Disable unnecessary network services
      firewall.enable = false; # Windows firewall handles this
    };

    # Environment optimizations
    environment = {
      variables = {
        BROWSER = "${system32}/cmd.exe /c start";
      };

      shellAliases = {
        cdwin = "cd ${winMount}/Users/${winUser}";
        explorer = "${winRoot}/explorer.exe";
        notepad = "${system32}/notepad.exe";
        cmd = "${system32}/cmd.exe";
        powershell = "${system32}/WindowsPowerShell/v1.0/powershell.exe";
        code = "'${vscodeBin}/code'";
      };
    };
  };
}
