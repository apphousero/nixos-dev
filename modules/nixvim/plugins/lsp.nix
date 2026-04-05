{
  config,
  lib,
  ...
}:
let
  helpers = import ../../lib.nix { inherit config; };
  inherit (helpers) hasNodejs hasPython hasGo hasJava;
in
{
  programs.nixvim.plugins = {
    lsp.enable = true;
    lsp-format.enable = true;
    trouble = {
      enable = true;
      settings = {
        auto_open = false;
        auto_close = true;
      };
    };
  };
  programs.nixvim.lsp = {
    enable = true;
    keymaps = [
      {
        key = "gd";
        lspBufAction = "definition";
      }
      {
        key = "gD";
        lspBufAction = "references";
      }
      {
        key = "gt";
        lspBufAction = "type_definition";
      }
      {
        key = "gi";
        lspBufAction = "implementation";
      }
      {
        key = "<leader>K";
        lspBufAction = "hover";
      }
      {
        action.__raw = "function() vim.diagnostic.jump({ count=-1, float=true }) end";
        key = "<leader>k";
      }
      {
        action.__raw = "function() vim.diagnostic.jump({ count=1, float=true }) end";
        key = "<leader>j";
      }
      {
        action = "<CMD>LspStop<Enter>";
        key = "<leader>lx";
      }
      {
        action = "<CMD>LspStart<Enter>";
        key = "<leader>ls";
      }
      {
        action = "<CMD>LspRestart<Enter>";
        key = "<leader>lr";
      }
      {
        action.__raw = "require('telescope.builtin').lsp_definitions";
        key = "gd";
      }
      {
        action = "<CMD>LspInfo<Enter>";
        key = "<leader>li";
      }
    ];
    servers = {
      bashls.enable = true;
      clangd.enable = true;
      cssls.enable = lib.mkDefault hasNodejs;
      csharp_ls = {
        # enable = lib.mkDefault hasDotnetSdk;
        enable = false;
        config = {
          cmd = [
            "csharp-ls"
            "--features"
            "metadata-uris"
          ];
        };
      };
      dockerls.enable = true;
      eslint.enable = lib.mkDefault hasNodejs;
      gopls = {
        enable = lib.mkDefault hasGo;
        config = {
          gofumpt = true;
          staticcheck = true;
          usePlaceholders = true;
        };
      };
      html.enable = lib.mkDefault hasNodejs;
      # htmx.enable = lib.mkDefault hasNodejs;
      htmx.enable = false;
      java_language_server.enable = lib.mkDefault hasJava;
      jsonls.enable = true;
      lua_ls.enable = true;
      marksman.enable = true;
      nil_ls = {
        enable = true;
        config = {
          autoArchive = true;
        };
      };
      pylsp = {
        enable = lib.mkDefault hasPython;
        config = {
          plugins = {
            pycodestyle.enabled = false;
            mccabe.enabled = false;
            pyflakes.enabled = false;
            flake8.enabled = true;
            autopep8.enabled = false;
            yapf.enabled = false;
            black.enabled = true;
            isort.enabled = true;
            mypy.enabled = true;
          };
        };
      };
      sqls.enable = true;
      ts_ls.enable = lib.mkDefault hasNodejs;
      yamlls.enable = true;
    };
  };
}
