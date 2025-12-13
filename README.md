# nixos-dev

[AppHouse NixOS Hosts Flake](https://nixos.wiki/wiki/flakes): same configuration, different scoped hosts.

To be used in upstream flakes but WSL can be used as standalone.

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

