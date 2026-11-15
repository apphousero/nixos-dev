{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.nixvim.extraConfigLua = lib.mkIf config.nixos-dev.nixvim.dotnet.enable ''
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
