{ ... }: {
  programs.nixvim.plugins.telescope = {
    enable = true;
    autoLoad = true;
    keymaps = {
      "<leader>ff" = "find_files";
      "<leader>fg" = "live_grep";
      "<leader>fb" = "buffers";
      "<leader>fh" = "help_tags";
    };
    extensions = {
      file-browser = {
        enable = true;
        settings = {
          hidden = true;
          respect_git_ignore = true;
        };
      };
    };
    settings = {
      defaults = {
        file_ignore_patterns = [
          "%.git/"
          "[Bb]in/"
          "[Oo]bj/"
          "~$"
        ];
      };
      pickers = {
        find_files = {
          hidden = true;
        };
        grep_string = {
          additional_args = [ "--hidden" ];
        };
        live_grep = {
          additional_args = [ "--hidden" ];
        };
      };
    };
  };
}
