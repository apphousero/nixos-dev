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
        settings = {
          hidden = true;
          respect_git_ignore = true;
        };
      };
    };
    settings = {
      defaults = {
        file_ignore_patterns = [
          ".git/"
          "[Bb]in/"
          "[Oo]bj/"
          "*~"
        ];
        hidden = true;
      };
      pickers = {
        find_files = {
          hidden = true;
        };
        grep_string = {
          additionl_args = [ "--hidden" ];
        };
        live_grep = {
          additionl_args = [ "--hidden" ];
        };
      };
    };
  };
}
