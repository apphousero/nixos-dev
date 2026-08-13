{
  config,
  devPackages,
  lib,
  pkgs,
  sharedPackages,
  zsh,
  ...
}:
let
  lspPackages = import ./nixvim/lsp-packages.nix { inherit config lib; };
in
{
  imports = [
    ./base.nix
  ];

  # Home configuration
  home.stateVersion = lib.mkDefault "26.05";
  home.enableNixpkgsReleaseCheck = false;
  manual.manpages.enable = lib.mkDefault false;
  # Force stuff
  home.file.".bashrc".force = true;
  home.file.".profile".force = true;

  _module.args.isNixOS = false;
  _module.args.nixvim = {
    copilot = {
      chat = false;
      code = false;
    };
    dotnet = {
      useOmnisharp = true;
    };
  };

  # ── Packages (shared + home-only) ──────────────────────────────────────
  home.packages =
    sharedPackages
    ++ devPackages
    ++ lspPackages
    ++ (with pkgs; [
      spotify-player
    ]);

  programs.oh-my-pi.enable = true;

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
