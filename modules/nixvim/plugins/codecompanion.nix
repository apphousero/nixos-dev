{ config, ... }:
let
  adapter = {
    name = "mistral";
    model = "zai-glm-latest";
  };
in
{
  programs.nixvim.plugins.codecompanion = {
    enable = config.nixos-dev.nixvim.mistral.chat;
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
          return require("codecompanion.adapters").extend("mistral", {
            schema = {
              model = {
                default = "${adapter.model}",
              },
            },
            handlers = {
              chat_output = function(self, data, tools)
                if not data or data == "" then
                  return nil
                end
                local body = type(data) == "table" and data.body or data:sub(data:find("{", 1, true) or 1)
                local ok, json = pcall(vim.json.decode, body, { luanil = { object = true } })
                if not ok or type(json) ~= "table" or type(json.choices) ~= "table" then
                  return base.handlers.chat_output(self, data, tools)
                end
                local patched = false
                for _, choice in ipairs(json.choices) do
                  for _, call in ipairs(choice.delta and choice.delta.tool_calls or {}) do
                    local known = tools and call.index and tools[call.index + 1]
                    if (call.id == nil or call.id == "") and known then
                      call.id = known.id
                      patched = true
                    end
                  end
                end
                local result = base.handlers.chat_output(self, patched and { body = vim.json.encode(json) } or data, tools)
                if not (result and result.output and result.output.reasoning) then
                  return result
                end
                local choice = json.choices[1]
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
        chat = {
          inherit adapter;
          tools = {
            opts.default_tools = [ "files" ];
            grep_search.opts.require_approval_before = false;
            read_file.opts.require_approval_before = false;
            file_search.opts.require_approval_before = false;
            get_changed_files.opts.require_approval_before = false;
          };
        };
        inline.adapter = adapter;
        cmd.adapter = adapter;
        background.adapter = adapter;
      };
    };
  };
}
