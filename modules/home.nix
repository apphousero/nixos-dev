{
  config,
  devPackages,
  dotnetSdk,
  lib,
  pkgs,
  sharedPackages,
  sharedShellAliases,
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
  home.enableNixpkgsReleaseCheck = false;
  manual.manpages.enable = lib.mkDefault false;
  # Force stuff
  home.file.".bashrc".force = true;
  home.file.".profile".force = true;

  _module.args.isNixOS = false;
  nixos-dev.nixvim = {
    mistral = {
      chat = lib.mkDefault true;
      code = lib.mkDefault true;
    };
    dotnet.useOmnisharp = lib.mkDefault true;
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

  home.shellAliases = sharedShellAliases;

  # ── Environment variables ───────────────────────────────────────────────
  home.sessionVariables = {
    VISUAL = "nvim";
    EDITOR = "nvim";
    MC_SKIN = "dark";
    DOTNET_ROOT = "${dotnetSdk}/share/dotnet";
  };

  # ── Programs ────────────────────────────────────────────────────────────
  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      initExtra = ''
        if [[ $- == *i* ]] && [[ -x "${pkgs.zsh}/bin/zsh" ]] && [[ "$(</proc/$PPID/comm)" != zsh ]]; then
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
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      initContent = ''
        ${zsh.promptInit}
        ${zsh.interactiveShellInit}
      '';
    };
  };
  # ── Services ───────────────────────────────────────────────────────────
  services.ssh-agent.enable = lib.mkDefault true;
}
