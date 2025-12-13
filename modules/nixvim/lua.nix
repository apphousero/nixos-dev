{
  config,
  lib,
  pkgs,
  ...
}:
let
  hasPackage =
    pkg: builtins.any (p: p.pname or p.name or "" == pkg) config.environment.systemPackages;
  hasDotnetSdk = hasPackage "dotnet" || hasPackage "dotnet-sdk" || hasPackage "dotnet-sdk_8";

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
