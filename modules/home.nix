{
  pkgs,
  ...
}:
{
  imports = [
    ./base.nix
  ];

  # ── Packages (mirrors base.nix environment.systemPackages) ──────────────
  home.packages = with pkgs; [
    ast-grep
    atac
    atuin
    bat
    btop
    coreutils
    curl
    dive
    dos2unix
    duf
    dust
    eza
    fastfetch
    fd
    file
    fh
    fzf
    gcc
    gnumake
    htop
    jq
    lazygit
    lazyjournal
    lsof
    mc
    nano
    ncdu
    nerdfetch
    neofetch
    nitch
    nix-tree
    nix-output-monitor
    nushell
    openssl
    python3
    superfile
    ripgrep
    rsync
    age
    sops
    ssh-to-age
    tldr
    tree
    tmux
    unzip
    wget
    zellij
    zip
    zoxide
  ];

  # ── Environment variables ───────────────────────────────────────────────
  home.sessionVariables = {
    VISUAL = "nvim";
    EDITOR = "nvim";
    MC_SKIN = "dark";
  };
}
