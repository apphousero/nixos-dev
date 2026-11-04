{
  pkgs,
  lib,
  ...
}:
let
  dotnetSdk =
    with pkgs.dotnetCorePackages;
    combinePackages [
      sdk_8_0
      sdk_10_0
    ];
in
{
  # Import configurations
  imports = [
    ./nixvim
    ./tmux
  ];

  # True if it is NixOS install, false if it is other OS with Nix and Home Manager
  _module.args.isNixOS = lib.mkDefault true;
  _module.args.dotnetSdk = dotnetSdk;

  # Shared packages available in both NixOS and Home Manager contexts
  _module.args.sharedPackages = with pkgs; [
    # Custom tmux session launcher
    (writeScriptBin "mm" (builtins.readFile ./scripts/sh/mm.sh))
    # Attach to tmux, or resurrect the last saved session if none is running
    (writeShellScriptBin "rmux" ''
      export RESTORE_SCRIPT="${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/restore.sh"
      ${builtins.readFile ./scripts/sh/rmux.sh}
    '')
    # Grep for something else
    ast-grep
    # Simple CLI GUI Postman like
    atac
    # Can't remember
    (if stdenv.hostPlatform.isAarch64 then atuin.overrideAttrs { doCheck = false; } else atuin)
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
    # Audio/video CLI (ffmpeg, ffprobe)
    ffmpeg-headless
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
    # killall, fuser, pstree, etc.
    psmisc
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
    # Extra zsh completion definitions
    zsh-completions
  ];

  _module.args.devPackages = with pkgs; [
    # Azure CLI... needed, not wanted
    #azure-cli
    # Python package manager and runner (provides uvx)
    uv
    # .NET SDK packages
    dotnetSdk
    # Aider
    # aider-chat-full
    # Claude
    claude-code
    # Some lil DOS box for development
    dosbox
    # HTML Tools
    htmlq
    hyperfine
    # Github CLI
    gh
    # GCP CLI
    google-cloud-sdk
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
    # For docs
    python3Packages.markitdown
    pandoc
    python3Packages.virtualenv
    (texliveSmall.withPackages (
      ps: with ps; [
        latex-bin
        latexmk
        xcolor
      ]
    ))
    # HTTP load testing tool
    vegeta
    # XML
    libxml2
    libxslt
    # NodeJS package manager
    yarn
  ];

  # Shared shell aliases deployed identically in both contexts:
  # NixOS via `environment.shellAliases`, Home Manager via `home.shellAliases`
  # (both feed bash and zsh).
  _module.args.sharedShellAliases = {
    la = "eza -la";
    l = "la";
    lzd = "lazydocker";
    lg = "lazygit";
    lj = "lazyjournal";
    gs = "git status";
    node24 = "nix shell nixpkgs#nodejs_24";
    node22 = "nix shell nixpkgs#nodejs_22";
    node20 = "nix shell nixpkgs#nodejs_20";
    md = "mkdir -p";
    myvim = "nvim .";
    mn = "myvim";
    o = "omp";
    rtty = "clear; exec $SHELL";
    n = "nitch";
    ta = "tmux attach";
    tk = "tmux kill-session";
    txx = "tmux kill-server";
  };

  _module.args.zsh = {
    promptInit = ''
      # Plugins from ThePrimeagen’s setup
      source ${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use/you-should-use.plugin.zsh
      source ${pkgs.zsh-z}/share/zsh-z/zsh-z.plugin.zsh

      # Prompt (powerlevel10k, as in video)
      source ${pkgs.zsh-powerlevel10k}/share/zsh/themes/powerlevel10k/powerlevel10k.zsh-theme
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      eval "$(atuin init zsh)"

      # Disable flow control so CTRL+Q, CTRL+S can be used for bindings (tmux in ssh)
      stty -ixon
      if [[ -z $TMUX ]]; then
        nitch
      fi
    '';
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
