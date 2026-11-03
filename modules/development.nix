{
  devPackages,
  dotnetSdk,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./common.nix
  ];

  nixos-dev.nixvim = {
    mistral = {
      chat = lib.mkDefault true;
      code = lib.mkDefault true;
    };
    dotnet.useOmnisharp = lib.mkDefault true;
  };

  # Development system packages that should be available everywhere
  environment.systemPackages = devPackages ++ [
    pkgs.oh-my-pi
    pkgs.putty
  ];

  environment.sessionVariables = {
    DOTNET_ROOT = "${dotnetSdk}/share/dotnet";
  };
}
