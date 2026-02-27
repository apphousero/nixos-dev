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

  # Copilot disabled by default
  _module.args.copilot = lib.mkDefault {
    chat = false;
    code = false;
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
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
