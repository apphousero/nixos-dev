{
  config,
  lib,
  ...
}:
let
  cfg = config.nixos-dev.nixvim;
  mistralCode = cfg.mistral.code;
in
{
  programs.nixvim.plugins = {
    cmp = {
      enable = true;
      autoEnableSources = true;
      settings = {
        mapping = {
          "<C-p>" = "cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select })";
          "<C-n>" = "cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select })";
          "<C-y>" = "cmp.mapping.confirm({ select = true })";
          "<C-f>" = "cmp.mapping.complete()";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
        }
        // lib.optionalAttrs mistralCode {
          "<A-y>" = "require('minuet').make_cmp_map()";
        };
        performance = lib.optionalAttrs mistralCode {
          fetching_timeout = 2000;
        };
        sources =
          lib.optionals cfg.copilot.code [
            {
              name = "copilot";
              group_index = 2;
            }
          ]
          ++ lib.optionals mistralCode [
            {
              name = "minuet";
              group_index = 2;
            }
          ]
          ++ [
            {
              name = "nvim_lsp";
              group_index = 2;
            }
            {
              name = "luasnip";
              group_index = 2;
            }
            {
              name = "buffer";
              group_index = 2;
            }
            {
              name = "path";
              group_index = 2;
            }
          ];
      };
    };
    cmp-buffer.enable = true;
    cmp-nvim-lsp.enable = true;
    cmp-path.enable = true;
    luasnip.enable = true;
  };
}
