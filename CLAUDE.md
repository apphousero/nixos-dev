# Claude Project Instructions

## Project Overview

This is a public Determinate Nix configuration flake at [apphousero/nixos-dev](https://github.com/apphousero/nixos-dev).

This flake is referenced by other flakes - changes may affect downstream consumers.

## Structure

- `flake.nix` - Main flake with `homeModules` and `nixosModules` exports
- `flake.lock` - Lock file
- `hosts/` - Host-specific configurations (`dev.nix`, `wsl.nix`, `desktop.nix`)
- `modules/` - Reusable NixOS modules
  - `base.nix` - Base configuration
  - `common.nix` - Shared/common configuration
  - `home.nix` - Home Manager configuration
  - `lib.nix` - Library/utility functions
  - `development.nix` - Development tools
  - `desktop.nix` - Desktop environment
  - `server.nix` - Server configuration
  - `server-containers.nix` - Server container configuration
  - `wsl.nix` - WSL-specific settings
  - `nixvim/` - Neovim configuration via nixvim
    - `colorschemes.nix`, `globals.nix`, `keymaps.nix`, `lua.nix`, `opts.nix`
    - `mini/`, `plugins/`, `default.nix`, `README.md`
  - `tmux/` - Tmux configuration
    - `default.nix`
  - `scripts/` - Custom scripts (`sh/`)
- `packages/` - Custom Nix packages
  - `pi.nix` - `pi` AI coding agent package
  - `update-aph-pi.sh` - Script to update `pi` version
  - `README.md` - Package documentation
- `res/samples/` - Sample configurations
- `.github/workflows/build-and-publish.yml` - CI/CD pipeline
- `.env` / `.env/secrets` - Environment variables and secrets

## Flake Exports

### `nixosModules`
- `development` - Full development module (imports home-manager, nixvim, determinate, development.nix)
- `desktop` - Full desktop module (imports home-manager, nixvim, determinate, desktop.nix)

### `homeModules`
- `default` - Home Manager configuration (imports nixvim, home.nix)

Host-specific modules (`devModules`, `desktopModules`, `wslModules`) are applied inside the flake's `nixosConfigurations` based on hostname.

## Key Dependencies

- nixpkgs (unstable)
- home-manager
- nixvim
- nixos-wsl
- vscode-server
- determinate

## Guidelines

- Use Nix formatting conventions (nixfmt-style)
- Test changes with `nix flake check` before committing
- Consider both x86_64-linux and aarch64-linux architectures
- Remember this flake exports nixosModules consumed by other flakes

## Test Build

Test using the following command (ask about architecture first):

```sh
nix build .#nixosConfigurations.wsl-x86_64.config.system.build.toplevel --show-trace
nix build .#nixosConfigurations.wsl-aarch64.config.system.build.toplevel --show-trace
```
