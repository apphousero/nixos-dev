{
  description = "AppHouse NixOS configuration";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
    nixvim = { url = "github:nix-community/nixvim"; };
    home-manager = { url = "github:nix-community/home-manager"; };
    nixos-wsl = { url = "github:nix-community/NixOS-WSL"; };
    vscode-server = { url = "github:nix-community/nixos-vscode-server"; };
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
    };
  };

  outputs =
    {
      nixpkgs,
      nixvim,
      home-manager,
      nixos-wsl,
      self,
      vscode-server,
      determinate,
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
                determinate.nixosModules.default
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
      homeModules = {
        default =
          {
            config,
            pkgs,
            lib,
            ...
          }:
          {
            imports = [
              nixvim.homeModules.nixvim
              ./modules/home.nix
            ];
          };
      };

      nixosModules = {
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
              determinate.nixosModules.default
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
              determinate.nixosModules.default
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
              determinate.nixosModules.default
              ./modules/server.nix
            ];
          };
        server-containers =
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
              determinate.nixosModules.default
              ./modules/server-containers.nix
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
              determinate.nixosModules.default
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
      homeConfigurations =
        let
          mkHome =
            system:
            home-manager.lib.homeManagerConfiguration {
              pkgs = nixpkgs.legacyPackages.${system};
              modules = [
                nixvim.homeModules.nixvim
                ./modules/home.nix
                {
                  home.username = "andrei";
                  home.homeDirectory = "/home/andrei";
                }
              ];
            };
        in
        {
          "home-x86_64" = mkHome systemX86_64;
          "home-aarch64" = mkHome systemAarch64;
        };
    };
}
