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
      chat = true;
      code = true;
    };
    dotnet = {
      useOmnisharp = true;
    };
  };

  # Development system packages that should be available everywhere
  environment.systemPackages =
    devPackages
    ++ (with pkgs; [
    ]);

  environment.sessionVariables = {
    DOTNET_ROOT = "${pkgs.dotnetCorePackages.sdk_10_0}";
    MC_SKIN = "dark";
  };
  #nixpkgs.config.permittedInsecurePackages = [
  #  "dotnet-sdk-6.0.428"
  #];
}
