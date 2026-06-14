{
  config,
  lib,
  pkgs,
  sharedPackages,
  zsh,
  ...
}:
{
  imports = [
    ./base.nix
  ];

  # NixOS state version - this should be set per host
  system.stateVersion = lib.mkDefault "26.05";

  _module.args.isNixOS = true;

  # Basic system configuration that all systems should have
  nix = {
    # Automatic garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    settings = {
      # Trusted users for binary cache
      trusted-users = [
        "root"
        "@wheel"
      ];

      # Substituters
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        "https://cache.flakehub.com"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      ];

      # Use all available CPU cores for parallel builds
      max-jobs = lib.mkDefault "auto";
      cores = lib.mkDefault 0;

      # Parallel substitution downloads
      http-connections = lib.mkDefault 128;
      max-substitution-jobs = lib.mkDefault 128;
    };
  };

  environment.sessionVariables = {
    MC_SKIN = "dark";
  };

  # Basic system packages that should be available everywhere
  environment.systemPackages =
    sharedPackages
    ++ (with pkgs; [
    ]);

  environment.variables = {
    VISUAL = "nvim";
    EDITOR = "nvim";
  };

  # Locale and timezone (can be overridden per host)
  time.timeZone = lib.mkDefault "Europe/Bucharest";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  # Some nerd fonts
  fonts = {
    enableDefaultPackages = true;
    enableGhostscriptFonts = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
      };
    };
  };

  # Basic security settings
  security = {
    # Don't allow users to install packages without sudo
    sudo = {
      enable = true;
      wheelNeedsPassword = lib.mkDefault false;
    };
  };

  networking = {
    enableIPv6 = lib.mkDefault true;
    # Basic firewal
    firewall = {
      enable = lib.mkDefault true;
      allowPing = lib.mkDefault true;
      allowedTCPPorts = lib.mkDefault [ ];
      allowedUDPPorts = lib.mkDefault [ ];
    };
  };

  # Services that should be running on all systems
  services = {
    # SSH with reasonable defaults
    openssh = {
      enable = lib.mkDefault false;
      settings = {
        PasswordAuthentication = lib.mkDefault false;
        PermitRootLogin = lib.mkDefault "no";
        ChallengeResponseAuthentication = false;
        X11Forwarding = lib.mkDefault false;
      };
    };
  };

  # System settings
  system = {
    # Link the system build revision to the flake
    configurationRevision = lib.mkIf (
      config.system.nixos.revision != null
    ) config.system.nixos.revision;
  };

  # Basic user configuration
  users = {
    # Disable mutable users by default (declare users in configuration)
    mutableUsers = lib.mkDefault false;
    # Default shell
    defaultUserShell = pkgs.zsh;
    # Allow no password login
    allowNoPasswordLogin = lib.mkDefault true;
  };

  documentation = {
    enable = lib.mkDefault false;
    nixos.enable = lib.mkDefault false;
    man.enable = lib.mkDefault true;
  };

  # Basic shell configuration
  programs = {
    bash = {
      completion = {
        enable = lib.mkDefault true;
      };
      enableLsColors = true;
    };
    git = {
      enable = true;
      config = {
        init.defaultBranch = "master";
        core.autocrlf = false;
      };
    };
    nix-index.enable = true;
    # Enable nix-ld for running dynamic executables
    nix-ld = {
      enable = lib.mkDefault true;
      libraries = with pkgs; [
        stdenv.cc.cc
        zlib
        openssl
      ];
    };
    ssh.startAgent = lib.mkDefault true;
    yazi = {
      enable = lib.mkDefault true;
      settings = {
        yazi = {
          show_hidden = true;
          show_symlink = true;
        };
      };
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      promptInit = zsh.promptInit;
      shellAliases = zsh.shellAliases;
      interactiveShellInit = zsh.interactiveShellInit;
    };
  };
}
