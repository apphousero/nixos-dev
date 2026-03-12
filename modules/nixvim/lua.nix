{
  config,
  lib,
  pkgs,
  ...
}:
let
  packages =
    (if config ? environment then config.environment.systemPackages or [] else [])
    ++ (if config ? home then config.home.packages or [] else []);
  hasPackage = pkg: builtins.any (p: p.pname or p.name or "" == pkg) packages;
  hasDotnetSdk = hasPackage "dotnet" || hasPackage "dotnet-sdk" || hasPackage "dotnet-sdk-wrapped";

in
{
  programs.nixvim.extraConfigLua = lib.mkIf hasDotnetSdk ''
    local dap = require('dap')
    dap.adapters.coreclr = {
        type = 'executable',
        command = '${pkgs.netcoredbg}/bin/netcoredbg',
        args = { '--interpreter=vscode' }
      }
      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "launch - netcoredbg",
          request = "launch",
          program = function()
            return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/', 'file')
            end,
        },
      }
  '';
}
