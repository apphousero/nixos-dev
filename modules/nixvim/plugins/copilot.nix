{
  config,
  lib,
  ...
}:
let
  cfg = config.nixos-dev.nixvim;
in
{
  programs.nixvim.plugins = {
    copilot-lua = {
      enable = cfg.copilot.code || cfg.copilot.chat;
    };
    copilot-cmp = {
      enable = cfg.copilot.code;
    };
    copilot-chat = {
      enable = cfg.copilot.chat;
    };
  };

  programs.nixvim.keymaps = lib.mkIf cfg.copilot.chat [
    {
      mode = "n";
      action = "<cmd>CopilotChatToggle<cr>";
      key = "<leader>cc";
      options = {
        desc = "Copilot Chat toggle";
        silent = true;
      };
    }
    {
      mode = "v";
      action = "<cmd>CopilotChatToggle<cr>";
      key = "<leader>cc";
      options = {
        desc = "Copilot Chat with selection";
        silent = true;
      };
    }
    {
      mode = "v";
      action = "<cmd>CopilotChatExplain<cr>";
      key = "<leader>ce";
      options = {
        desc = "Copilot explain selection";
        silent = true;
      };
    }
    {
      mode = "v";
      action = "<cmd>CopilotChatReview<cr>";
      key = "<leader>cr";
      options = {
        desc = "Copilot review selection";
        silent = true;
      };
    }
    {
      mode = "v";
      action = "<cmd>CopilotChatFix<cr>";
      key = "<leader>cf";
      options = {
        desc = "Copilot suggest fix";
        silent = true;
      };
    }
    {
      mode = "v";
      action = "<cmd>CopilotChatOptimize<cr>";
      key = "<leader>co";
      options = {
        desc = "Copilot optimize selection";
        silent = true;
      };
    }
    {
      mode = "n";
      action = "<cmd>CopilotChatTests<cr>";
      key = "<leader>ct";
      options = {
        desc = "Copilot generate tests";
        silent = true;
      };
    }
    {
      mode = "v";
      action = "<cmd>CopilotChatDocs<cr>";
      key = "<leader>cd";
      options = {
        desc = "Copilot generate docs for selection";
        silent = true;
      };
    }
    {
      mode = [
        "n"
        "v"
      ];
      action.__raw = ''
        function()
          local input = vim.fn.input("Quick Chat: ")
          if input ~= "" then
            vim.cmd("CopilotChat " .. input)
          end
        end
      '';
      key = "<leader>cq";
      options = {
        desc = "Copilot quick chat";
        silent = true;
      };
    }
    {
      mode = "n";
      action = "<cmd>CopilotChatModels<cr>";
      key = "<leader>cm";
      options = {
        desc = "Copilot select model";
        silent = true;
      };
    }
    {
      mode = "n";
      action = "<cmd>CopilotChatReset<cr>";
      key = "<leader>cx";
      options = {
        desc = "Copilot reset chat";
        silent = true;
      };
    }
  ];
}
