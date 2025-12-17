{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Import configurations
  imports = [
    ./nixvim
    ./scripts
    ./tmux
    ./zsh
  ];

  # Basic system configuration that all systems should have
  nix = {
    # Automatic garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # Optimize store automatically
    settings = {
      auto-optimise-store = true;

      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Trusted users for binary cache
      trusted-users = [
        "root"
        "@wheel"
      ];

      # Substituters
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  # Basic system packages that should be available everywhere
  environment.systemPackages = with pkgs; [
    # Grep for something else
    ast-grep
    # Simple CLI GUI Postman like
    atac
    # Can't remember
    atuin
    # Cause cat is not styled enough
    bat
    # Monitor resources
    btop
    # Required by scripts
    coreutils
    # Can't not have curl
    curl
    # Analyze docker image layers
    dive
    # dig command
    dig
    # dos2unix - too usefull in WSL2
    dos2unix
    # Disk utility
    duf
    # Tree list occupied space
    dust
    # Better ls
    eza
    # Faster then neofetch
    fastfetch
    # Easy alternative to find
    fd
    # file command
    file
    # Fuzzy finder
    fzf
    # GCC
    gcc
    # GIT
    git
    # GNU make
    gnumake
    # htop
    htop
    # JSON support in shell
    jq
    # lazy but for Git
    lazygit
    # lazy but for logs
    lazyjournal
    # lsof
    lsof
    # ls but for hardware
    lshw
    # A commander because I was raised in the '90s
    mc
    # nano text editor
    nano
    # Another disk utility
    ncdu
    # Another fetch
    nerdfetch
    # Cool distro display
    neofetch
    # Fastest fetch
    nitch
    # nixos generators
    nixos-generators
    # nix tree
    nix-tree
    # nix output monitor
    nix-output-monitor
    # NMap
    nmap
    # The new shell
    nushell
    # PeteTong
    python3
    # A super file explorer
    superfile
    # grep in rust
    ripgrep
    # good for plex
    rsync
    # ssh to age
    ssh-to-age
    # strace
    strace
    # tree command
    tree
    # To complete a shell, ya need tmux
    tmux
    # Unzip
    unzip
    # Vault CLI
    vault-bin
    # Alternative to curl
    wget
    # Dev alternative to tmux
    zellij
    # Zip
    zip
    # zoxide
    zoxide
    # An incomplete shell (needs a multiplexer)
    zsh
  ];

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

    # NixOS state version - this should be set per host
    stateVersion = lib.mkDefault "25.05";
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
    enable = lib.mkDefault true;
    nixos.enable = lib.mkDefault true;
    man.enable = lib.mkDefault true;
  };
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
