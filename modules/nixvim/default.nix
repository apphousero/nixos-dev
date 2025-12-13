{ config, pkgs, ... }:
let
  hasPackage =
    pkg: builtins.any (p: p.pname or p.name or "" == pkg) config.environment.systemPackages;
  hasDotnetSdk = hasPackage "dotnet" || hasPackage "dotnet-sdk" || hasPackage "dotnet-sdk_8";
  hasNodejs = hasPackage "nodejs";
in
{
  imports = [
    ./colorschemes.nix
    ./globals.nix
    ./keymaps.nix
    ./lua.nix
    ./opts.nix
    ./mini
    ./plugins
  ];
  programs.nixvim = {
    enable = true;
    autoCmd = [
      {
        event = [ "FileType" ];
        pattern = [
          "cs"
          "csproj"
        ];
        command = "setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab";
      }
      {
        event = [ "FileType" ];
        pattern = [ "nix" ];
        command = "setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab";
      }
    ];
    extraConfigVim = ''
      command! W w
    '';
    extraPackages =
      with pkgs;
      [
        gcc
        nil
      ]
      ++ lib.lists.optionals hasDotnetSdk [
        dotnet-sdk
        netcoredbg
        omnisharp-roslyn
      ]
      ++ lib.lists.optionals hasNodejs [
        nodejs
        nodePackages.prettier
        nodePackages.vscode-langservers-extracted
        vscode-js-debug
      ];
  };
}
