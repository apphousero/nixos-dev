{
  devPackages,
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

  # Home configuration
  home.stateVersion = lib.mkDefault "25.11";
  home.enableNixpkgsReleaseCheck = false;
  # Force stuff
  home.file.".bashrc".force = true;
  home.file.".profile".force = true;

  _module.args.isNixOS = false;
  _module.args.nixvim.copilot = {
    chat = true;
    code = true;
  };

  # ── Packages (shared + home-only) ──────────────────────────────────────
  home.packages =
    sharedPackages
    ++ devPackages
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
      initExtra = ''
        if [[ $- == *i* ]] && [[ -x "${pkgs.zsh}/bin/zsh" ]]; then
          exec "${pkgs.zsh}/bin/zsh"
        fi
      '';
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
      shellWrapperName = lib.mkDefault "y";
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
}
