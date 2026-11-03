{
  description = "AppHouse NixOS configuration";

  inputs = {
    nixpkgs = {
      url = "https://flakehub.com/f/NixOS/nixpkgs/0";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
    };
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
    };
    oh-my-pi-flake = {
      url = "github:apphousero/oh-my-pi-flake";
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
      vscode-server,
      determinate,
      oh-my-pi-flake,
      ...
    }@inputs:
    let
      systemAarch64 = "aarch64-linux";
      systemX86_64 = "x86_64-linux";
      localOverlay = _final: prev: {
        mistral-vibe = import ./packages/mistral-vibe.nix { pkgs = prev; };
      };
      overlaysModule = {
        nixpkgs.overlays = [
          oh-my-pi-flake.overlays.default
          localOverlay
        ];
      };
      commonModules = [
        home-manager.nixosModules.default
        nixvim.nixosModules.default
        determinate.nixosModules.default
      ];
      wslModules = [
        nixos-wsl.nixosModules.default
        vscode-server.nixosModules.default
        overlaysModule
        ./modules/wsl.nix
      ];
      mkModule = modules: { imports = commonModules ++ modules; };
      hostModules = {
        dev = [
          overlaysModule
          ./modules/development.nix
        ];
        desktop = [
          overlaysModule
          ./modules/desktop.nix
        ];
        wsl = wslModules;
      };
      mkSystem =
        system: hostname:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = commonModules ++ hostModules.${hostname} ++ [ (./hosts + "/${hostname}.nix") ];
        };
    in
    {
      homeModules.default = {
        imports = [
          nixvim.homeModules.nixvim
          oh-my-pi-flake.homeManagerModules.default
          ./modules/home.nix
        ];
      };

      nixosModules = {
        development = mkModule hostModules.dev;
        desktop = mkModule hostModules.desktop;
        server = mkModule [ ./modules/server.nix ];
        server-containers = mkModule [ ./modules/server-containers.nix ];
        wsl = mkModule wslModules;
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
                self.homeModules.default
                {
                  home.username = "andrei";
                  home.homeDirectory = "/home/andrei";
                  home.stateVersion = "26.05";
                }
              ];
            };
        in
        {
          "home-x86_64" = mkHome systemX86_64;
          "home-aarch64" = mkHome systemAarch64;
        };

      packages = nixpkgs.lib.genAttrs [ systemX86_64 systemAarch64 ] (
        system:
        let
          pkgs' = nixpkgs.legacyPackages.${system};
          pkgsUnfree = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          pi-acp = pkgs'.callPackage ./packages/pi-acp.nix { };
          claude-agent-acp = pkgs'.callPackage ./packages/claude-agent-acp.nix { };
          aoaoe = pkgs'.callPackage ./packages/aoaoe.nix { };
          mistral-vibe = pkgsUnfree.callPackage ./packages/mistral-vibe.nix { };
        }
      );
    };
}
