{ ... }: {
  programs.nixvim.plugins = {
    cmp = {
      enable = true;
      autoEnableSources = true;
      settings = {
        mapping = {
          "<C-p>" = "cmp.mapping.select_prev_item(cmp_select)";
          "<C-n>" = "cmp.mapping.select_next_item(cmp_select)";
          "<C-y>" = "cmp.mapping.confirm({ select = true })";
          "<C-f>" = "cmp.mapping.complete()";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
        };
        sources = [
          { name = "nvim_lsp"; group_index = 2; }
          { name = "luasnip"; group_index = 2; }
          { name = "buffer"; group_index = 2; }
          { name = "path"; group_index = 2; }
        ];
      };
    };
    cmp-buffer.enable = true;
    cmp-cmdline.enable = true;
    cmp-nvim-lsp.enable = true;
    cmp-path.enable = true;
    cmp-zsh.enable = true;
    luasnip.enable = true;
  };
}
