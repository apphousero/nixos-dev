{
  pkgs,
  lib,
  ...
}:

{
  # Import configurations
  imports = [
    ./nixvim
    ./tmux
  ];

  # True if it is NixOS install, false if it is other OS with Nix and Home Manager
  _module.args.isNixOS = lib.mkDefault true;
  _module.args.nixvim = lib.mkDefault {
    copilot = {
      chat = false;
      code = false;
    };
    dotnet = {
      useOmnisharp = false;
    };
  };

  # Copilot disabled by default
  _module.args.copilot = lib.mkDefault {
  };

  # Shared packages available in both NixOS and Home Manager contexts
  _module.args.sharedPackages = with pkgs; [
    # Custom tmux session launcher
    (writeScriptBin "mm" (builtins.readFile ./scripts/sh/mm.sh))
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
    # dig DNSes
    dig
    # Analyze docker image layers
    dive
    # dos2unix - too usefull in WSL2
    dos2unix
    # Disk utility
    duf
    # Tree list occupied space
    dust
    # Better ls
    eza
    # Easy alternative to find
    fd
    # file command
    file
    # Flakehub CLI
    fh
    # Fuzzy finder
    fzf
    # GCC
    gcc
    # GNU make
    gnumake
    # Hetzner Cloud
    hcloud
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
    # A commander because I was raised in the '90s
    mc
    # ls but for hardware
    lshw
    # nano text editor
    nano
    # Another disk utility
    ncdu
    # Fastest fetch
    nitch
    # nix tree
    nix-tree
    # nix output monitor
    nix-output-monitor
    # nixos generators
    nixos-generators
    # NMap
    nmap
    # The new shell
    nushell
    # OpenSSL
    openssl
    # PostgreSQL client
    postgresql
    # PeteTong
    python3
    # A super file explorer
    superfile
    # grep in rust
    ripgrep
    # good for plex
    rsync
    # age stuff for sops
    age
    sops
    ssh-to-age
    # sqlite and tools
    sqlite
    litecli
    sqlite-utils
    # strace
    strace
    # TCP dump
    tcpdump
    # tldr any command instead of man, e.g. tldr fd
    tldr
    # tree command
    tree
    # Unzip
    unzip
    # Alternative to curl
    wget
    # Vault CLI
    vault-bin
    # Dev alternative to tmux
    zellij
    # Zip
    zip
    # zoxide
    zoxide
  ];

  _module.args.devPackages = with pkgs; [
    # Azure CLI... needed, not wanted
    #azure-cli
    # .NET SDK packages
    (
      with dotnetCorePackages;
      combinePackages [
        sdk_8_0
        sdk_10_0
      ]
    )
    # Claude
    claude-code
    # Some lil DOS box for development
    dosbox
    # Analyse docker images
    dive
    # Github CLI
    gh
    # GCP CLI
    google-cloud-sdk
    # and Gemini CLI
    gemini-cli
    # ping but with graph
    gping
    # kubectl and its relatives
    kubectl
    kubectx
    kubernetes-helm
    kustomize
    k9s
    # lazy but for Docker
    lazydocker
    # lazy SQL
    lazysql
    # NodeJS
    nodejs_24
    #nodejs_20
    #nodejs_18
    node-gyp
    # aaah, mermaid
    mermaid-cli
    # HTTP load generator
    oha
    # For certificates
    openssl
    # For docs
    pandoc
    python3Packages.virtualenv
    (texlive.combine {
      inherit (texlive)
        scheme-basic
        latex-bin
        latexmk
        xcolor
        ;
    })
    # tldr any command instead of man, e.g. tldr fd
    tldr
    # HTTP load testing tool
    vegeta
    # NodeJS package manager
    yarn
  ];

  _module.args.zsh = {
    promptInit = ''
      # Load zinit
      if [[ ! -f ~/.zinit/bin/zinit.zsh ]]; then
        mkdir -p ~/.zinit
        git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin
      fi
      source ~/.zinit/bin/zinit.zsh

      # Plugins from ThePrimeagen’s setup
      zinit light zsh-users/zsh-autosuggestions
      zinit light zsh-users/zsh-syntax-highlighting
      zinit light zsh-users/zsh-completions
      zinit light djui/alias-tips
      zinit light agkozak/zsh-z

      # Prompt (powerlevel10k, as in video)
      zinit light romkatv/powerlevel10k
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      eval "$(atuin init zsh)"

      # Disable flow control so CTRL+Q, CTRL+S can be used for bindings (tmux in ssh)
      stty -ixon
      if [[ -z $TMUX ]]; then
        nitch
      fi
    '';
    shellAliases = {
      la = "eza -la";
      l = "la";
      ld = "lazydocker";
      lg = "lazygit";
      lj = "lazyjournal";
      gs = "git status";
      node24 = "nix shell nixpkgs#nodejs_24";
      node22 = "nix shell nixpkgs#nodejs_22";
      node20 = "nix shell nixpkgs#nodejs_20";
      node18 = "nix shell nixpkgs#nodejs_18";
      myvim = "nvim .";
      mn = "myvim";
      rtty = "clear; exec $SHELL";
      n = "nitch";
      tk = "tmux kill-session";
    };
    interactiveShellInit = ''
      shhh() {
        if [[ -n "$SSH_CONNECTION" || -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
          echo "🚫 Cannot shutdown - you're in an SSH session!"
          echo "Disconnect first or use 'sudo shutdown now' if you really mean it."
        else
          sudo shutdown now
        fi
      }
    '';

  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
