{
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

  home.stateVersion = lib.mkDefault "25.11";
  home.enableNixpkgsReleaseCheck = false;

  _module.args.copilot = {
    chat = true;
    code = true;
  };

  # ── Packages (shared + home-only) ──────────────────────────────────────
  home.packages =
    sharedPackages
    ++ (with pkgs; [
      spotify-player
    ]);

  # ── Environment variables ───────────────────────────────────────────────
  home.sessionVariables = {
    VISUAL = "nvim";
    EDITOR = "nvim";
    MC_SKIN = "dark";
  };

  # ── Programs ────────────────────────────────────────────────────────────
  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
    };
    git = {
      enable = true;
      settings = {
        init.defaultBranch = "master";
        core.autocrlf = false;
      };
    };
    nix-index.enable = true;
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
      shellAliases = zsh.shellAliases;
      initContent = ''
        ${zsh.promptInit}
        ${zsh.interactiveShellInit}
      '';
    };
  };
  # ── Services ───────────────────────────────────────────────────────────
  services.ssh-agent.enable = lib.mkDefault true;
  # Force stuff
  home.file.".bashrc".force = true;
  home.file.".profile".force = true;
}
