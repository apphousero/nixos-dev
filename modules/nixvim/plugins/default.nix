{ ... }:
{
  imports = [
    ./cmp.nix
    ./lsp.nix
    ./telescope.nix
    ./treesitter.nix
  ];
  programs.nixvim.plugins = {
    dap = {
      enable = true;
    };
    dap-ui.enable = true;
    nvim-tree = {
      enable = true;
      settings = {
        auto_reload_on_write = true;
        disable_netrw = false;
        hijack_cursor = false;
        hijack_netrw = true;
        hijack_unnamed_buffer_when_opening = true;
        view = {
          width = 50;
        };
      };
    };
    undotree = {
      enable = true;
      autoLoad = true;
    };
    web-devicons.enable = true;
  };
}
