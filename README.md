# nixos-dev

[AppHouse NixOS Hosts Flake](https://nixos.wiki/wiki/flakes): same configuration, different scoped hosts.

To be used in upstream flakes but WSL can be used as standalone.

Also provides a `homeManagerModules` output for non-NixOS systems where Nix is used as a package manager.

## Prerequisites `nerd-fonts`

In order for `nerd-fonts` to work in `WSL2` use [this repo ryanoasis/nerd-fonts](https://github.com/ryanoasis/nerd-fonts) as a source:
and run the following command in `Powershell` in `Windows`
`& ([scriptblock]::Create((iwr 'https://to.loredo.me/Install-NerdFont.ps1')))`

## Apply to Current NixOS System

### __x86_64__

```sh
sudo nixos-rebuild switch --flake .#wsl-x86_64 --show-trace
sudo nixos-rebuild switch --flake github:apphousero/nixos-dev#wsl-x86_64
```

### __ARM64__

```sh
sudo nixos-rebuild switch --flake .#wsl-aarch64 --show-trace
sudo nixos-rebuild switch --flake github:apphousero/nixos-dev#wsl-aarch64
```

## Use as Home Manager Module (non-NixOS)

### Apply Directly

```sh
# x86_64
nix run home-manager -- switch --flake github:apphousero/nixos-dev#myuser

# or from local checkout
home-manager switch --flake .#myuser
```

### Use in Another Flake

```nix
{
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-dev = {
      url = "github:apphousero/nixos-dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nixos-dev, ... }: {
    homeConfigurations."myuser" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        nixos-dev.homeManagerModules.default
        {
          home.username = "myuser";
          home.homeDirectory = "/home/myuser";
          home.stateVersion = "24.11";
        }
      ];
    };
  };
}
```

## Apply as Standalone Home Manager (non-NixOS)

### __x86_64__

```sh
# 1. Determinate Nix
curl --proto '=https' --tlsv1.2 -sSf -L \
  https://install.determinate.systems/nix | sh -s -- install
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# 2. Home Manager CLI
nix profile install home-manager/master#home-manager

# 3. Apply your flake
home-manager switch --flake github:apphousero/nixos-dev#home-aarch64
# OR
home-manager switch --flake github:apphousero/nixos-dev#home-x86_64
```
## Bump Versions

```sh
nix flake update
```

## Garbage Collection

Perform a cleanup from time to time:

```sh
sudo nix-collect-garbage -d
```

## Rollback

```sh
sudo nixos-rebuild switch --rollback
```

## Development

Build without applying configuration:

```sh
nixos-rebuild build --flake .#wsl-aarch64
nixos-rebuild build --flake .#wsl-x86_64
nix run home-manager/master -- build --flake .#home-aarch64 \
      --extra-experimental-features nix-command --extra-experimental-features flakes
nix run home-manager/master -- build --flake .#home-x86_64 \
      --extra-experimental-features nix-command --extra-experimental-features flakes
```

## Build ISO

```sh
nix build --flake .#nixosConfigurations.desktop-x86_64.config.system.build.isoImage
nix build --flake github:apphousero/nixos-dev#nixosConfigurations.desktop-x86_64.config.system.build.isoImage
```

## Build WSL Distro From Scratch

### Use Ubuntu WSL

Install ```nix``` package manager (single-user):

```sh
sh <(curl -L https://nixos.org/nix/install) --no-daemon
```

Follow the next instruction from _install script_ then proceed.

Build into a ```result```, which is a symlink:

```sh
nix build github:apphousero/nixos-dev#nixosConfigurations.wsl-aarch64.config.system.build.tarballBuilder \
        --extra-experimental-features nix-command --extra-experimental-features flakes \
        --out-link result \
    && echo "Running result..." \
    && sudo ./result/bin/nixos-wsl-tarball-builder \
    && sudo mv nixos.wsl nixos-wsl.tar.gz \
    && sudo chown andrei:users nixos-wsl.tar.gz
```

Move resulting file to host OS user folder:

```sh
mkdir  /mnt/c/Users/{{username}}/NixOS
mv nixos-wsl.tar.gz /mnt/c/Users/{{username}}/NixOS
```

Change to ```powershell``` on host OS and run:

```powershell
cd $env:USERPROFILE\NixOS\
wsl --import NixOS $env:USERPROFILE\NixOS\ nixos-wsl.tar.gz --version 2
```

