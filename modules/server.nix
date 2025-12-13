{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./base.nix
  ];
  environment.systemPackages = with pkgs; [
    # Analyse docker images
    dive
    # ping but with graph
    gping
    # For certificates
    openssl
    # tldr any command instead of man, e.g. tldr fd
    tldr
  ];
  environment.sessionVariables = {
    MC_SKIN = "dark";
  };

  # Select internationalisation properties.
  console.keyMap = lib.mkDefault "us";

  networking = {
    firewall = {
      enable = lib.mkDefault true;
    };
  };

  users.users = {
    # Disable root login
    root.hashedPassword = lib.mkDefault "!";
  };

  security.sudo.wheelNeedsPassword = false;

  # Configure fail2ban
  services = {
    fail2ban = {
      enable = lib.mkDefault true;
      maxretry = lib.mkDefault 10;
      ignoreIP = [
        "127.0.0.1/8"
      ];
      bantime = lib.mkDefault "1h";
      bantime-increment = {
        enable = lib.mkDefault true;
        multipliers = "1 2 4 8 16 32 64";
        maxtime = "168h";
        overalljails = true;
      };
    };
    openssh = {
      #enable = lib.mkDefault true;
      settings = {
        PermitRootLogin = lib.mkDefault "no";
        PasswordAuthentication = lib.mkDefault false;
        KbdInteractiveAuthentication = lib.mkDefault false;
      };
    };
  };
  # Podman configuration
  virtualisation.containers.enable = lib.mkDefault true;
  virtualisation.podman = {
    enable = lib.mkDefault true;
    dockerCompat = lib.mkDefault true;
    defaultNetwork.settings.dns_enabled = lib.mkDefault true;
  };
}
