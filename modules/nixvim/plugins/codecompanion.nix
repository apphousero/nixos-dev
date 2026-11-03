{ ... }:
let
  adapter = {
    name = "mistral";
    model = "zai-glm-latest";
  };
in
{
  programs.nixvim.plugins.codecompanion = {
    enable = true;
    luaConfig.pre = ''
      if (vim.env.MISTRAL_API_KEY or "") ~= "" then
    '';
    luaConfig.post = ''
        for _, map in ipairs({
          { { "n", "v" }, "<leader>aa", "<cmd>CodeCompanionActions<cr>", "CodeCompanion actions" },
          { "n", "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", "CodeCompanion chat toggle" },
          { "v", "<leader>ac", ":CodeCompanionChat Add<cr>", "CodeCompanion add selection to chat" },
          { "n", "<leader>an", "<cmd>CodeCompanionChat<cr>", "CodeCompanion new chat" },
          { "n", "<leader>ai", "<cmd>CodeCompanion<cr>", "CodeCompanion inline prompt" },
          { "v", "<leader>ai", ":CodeCompanion<cr>", "CodeCompanion inline prompt on selection" },
          { "v", "<leader>ae", ":CodeCompanion /explain<cr>", "CodeCompanion explain selection" },
          { "v", "<leader>af", ":CodeCompanion /fix<cr>", "CodeCompanion fix selection" },
          { "v", "<leader>at", ":CodeCompanion /tests<cr>", "CodeCompanion tests for selection" },
        }) do
          vim.keymap.set(map[1], map[2], map[3], { desc = map[4], silent = true })
        end
      end
    '';
    settings = {
      adapters.http.mistral.__raw = ''
        function()
          local base = require("codecompanion.adapters.http.mistral")
          local utils = require("codecompanion.utils.adapters")
          return require("codecompanion.adapters").extend("mistral", {
            schema = {
              model = {
                default = "${adapter.model}",
                choices = {
                  ["zai-glm-latest"] = { opts = { can_reason = true, has_vision = false } },
                  ["mistral-medium-latest"] = { opts = { can_reason = true, has_vision = true } },
                },
              },
            },
            handlers = {
              chat_output = function(self, data, tools)
                local result = base.handlers.chat_output(self, data, tools)
                if not (result and result.output and result.output.reasoning) then
                  return result
                end
                local body = type(data) == "table" and data.body or utils.clean_streamed_data(data)
                local ok, json = pcall(vim.json.decode, body, { luanil = { object = true } })
                local choice = ok and json.choices and json.choices[1]
                local delta = choice and (self.opts.stream and choice.delta or choice.message)
                local text = ""
                for _, c in ipairs(type(delta and delta.content) == "table" and delta.content or {}) do
                  if c.type == "text" then
                    text = text .. c.text
                  end
                end
                if text ~= "" then
                  result.output.content = text
                end
                return result
              end,
            },
          })
        end
      '';
      interactions = {
        chat.adapter = adapter;
        inline.adapter = adapter;
        cmd.adapter = adapter;
        background.adapter = adapter;
      };
    };
  };
}
