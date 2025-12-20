# Claude Project Instructions

## Project Overview

This is a public NixOS configuration flake at [apphousero/nixos-dev](https://github.com/apphousero/nixos-dev).

This flake is referenced by other flakes - changes may affect downstream consumers.

## Structure

- `flake.nix` - Main flake with nixosModules exports (base, development, desktop, server, wsl)
- `hosts/` - Host-specific configurations (dev.nix, wsl.nix, desktop.nix)
- `modules/` - Reusable NixOS modules
  - `base.nix` - Base configuration
  - `development.nix` - Development tools
  - `desktop.nix` - Desktop environment
  - `server.nix` - Server configuration
  - `wsl.nix` - WSL-specific settings
  - `nixvim/` - Neovim configuration via nixvim
  - `tmux/` - Tmux configuration
  - `zsh/` - Zsh configuration
  - `scripts/` - Custom scripts

## Key Dependencies

- nixpkgs (unstable and 25.05 stable)
- home-manager
- nixvim
- nixos-wsl
- vscode-server

## Guidelines

- Use Nix formatting conventions (nixfmt-style)
- Test changes with `nix flake check` before committing
- Consider both x86_64-linux and aarch64-linux architectures
- Remember this flake exports nixosModules consumed by other flakes
