{
  description = "AppHouse NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixvim,
      home-manager,
      nixos-wsl,
      self,
      sops-nix,
      vscode-server,
      ...
    }@inputs:
    let
      systemAarch64 = "aarch64-linux";
      systemX86_64 = "x86_64-linux";
      mkSystem =
        system: hostname:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules =
            let
              baseModules = [
                home-manager.nixosModules.home-manager
                nixvim.nixosModules.nixvim
                sops-nix.nixosModules.default
                (./hosts + "/${hostname}.nix")
              ];
              devModules =
                if hostname == "dev" then
                  [
                    ./modules/development.nix
                  ]
                else
                  [ ];
              desktopModules =
                if hostname == "desktop" then
                  [
                    ./modules/desktop.nix
                  ]
                else
                  [ ];
              wslModules =
                if hostname == "wsl" then
                  [
                    ./modules/wsl.nix
                    nixos-wsl.nixosModules.default
                    vscode-server.nixosModules.default
                  ]
                else
                  [ ];
            in
            baseModules ++ devModules ++ wslModules ++ desktopModules;
        };
    in
    {
      nixosModules = {
        base =
          {
            config,
            pkgs,
            lib,
            ...
          }:
          {
            imports = [
              home-manager.nixosModules.default
              nixvim.nixosModules.default
              ./modules/base.nix
            ];
          };
        development =
          {
            config,
            pkgs,
            lib,
            ...
          }:
          {
            imports = [
              home-manager.nixosModules.default
              nixvim.nixosModules.default
              ./modules/development.nix
            ];
          };
        desktop =
          {
            config,
            pkgs,
            lib,
            ...
          }:
          {
            imports = [
              home-manager.nixosModules.default
              nixvim.nixosModules.default
              ./modules/desktop.nix
            ];
          };
        server =
          {
            config,
            pkgs,
            lib,
            ...
          }:
          {
            imports = [
              home-manager.nixosModules.default
              nixvim.nixosModules.default
              ./modules/server.nix
            ];
          };
        wsl =
          {
            config,
            pkgs,
            lib,
            ...
          }:
          {
            imports = [
              home-manager.nixosModules.default
              nixvim.nixosModules.default
              nixos-wsl.nixosModules.default
              vscode-server.nixosModules.default
              ./modules/wsl.nix
            ];
          };
      };
      nixosConfigurations = {
        # x86_64 configurations
        "dev-x86_64" = mkSystem systemX86_64 "dev";
        "wsl-x86_64" = mkSystem systemX86_64 "wsl";
        "desktop-x86_64" = mkSystem systemX86_64 "desktop";
        # aarch64 configurations
        "dev-aarch64" = mkSystem systemAarch64 "dev";
        "wsl-aarch64" = mkSystem systemAarch64 "wsl";
        "desktop-aarch64" = mkSystem systemAarch64 "desktop";
      };
    };
}
