{
  devPackages,
  pkgs,
  ...
}:
{
  imports = [
    ./common.nix
  ];

  _module.args.nixvim = {
    copilot = {
      chat = false;
      code = false;
    };
    dotnet = {
      useOmnisharp = true;
    };
  };

  # Development system packages that should be available everywhere
  environment.systemPackages = devPackages;

  environment.sessionVariables = {
    DOTNET_ROOT = "${pkgs.dotnetCorePackages.sdk_10_0}";
    MC_SKIN = "dark";
  };
}
