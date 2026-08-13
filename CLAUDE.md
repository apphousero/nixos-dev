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
  - `pi-acp.nix` - `pi-acp` ACP adapter package
  - `claude-agent-acp.nix` - `claude-agent-acp` package
  - `aoaoe.nix` - `aoaoe` supervisor package
  - `update-*.sh` - Scripts to update package versions
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
- Test changes with `nix flake check` before committing (fast — only validates syntax and types)
- Consider both x86_64-linux and aarch64-linux architectures
- Remember this flake exports nixosModules consumed by other flakes

## Build Timeouts

**Never let `nix build` run longer than 60 seconds.** Use `timeout 60` (or `timeout 30` for quick checks) on every `nix build` invocation. If it hasn't finished in that time, assume it's stuck or too expensive and stop. A full build of this flake takes minutes — it is **not** a quick validation step.

## Test Build

The default and recommended action is:

```sh
nix flake check
```

This validates syntax, types, and integrity quickly — use this for routine testing. A full `nix build` should only be run on **explicit user request** and must be capped with a timeout.

## Flake Update and Build

When asked to "flake update" (or "flake update and build", or similar), first run
`nix flake check` to validate syntax and types (fast). Then detect the current
running CPU architecture with `uname -m` and build for that architecture only.
Map `x86_64` to `wsl-x86_64` and `aarch64`/`arm64` to `wsl-aarch64`. Always print
the detected architecture so the user is aware of the build target. Only ask the
user if the architecture cannot be determined.

```sh
# x86_64 (uname -m == x86_64)
nix flake update
./packages/update-all.sh
nix flake check
timeout 60 nix build .#nixosConfigurations.wsl-x86_64.config.system.build.toplevel --show-trace

# aarch64 (uname -m == aarch64 / arm64)
nix flake update
./packages/update-all.sh
nix flake check
timeout 60 nix build .#nixosConfigurations.wsl-aarch64.config.system.build.toplevel --show-trace
```
