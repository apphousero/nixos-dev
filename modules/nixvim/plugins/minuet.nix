{ nixvim, ... }:
{
  programs.nixvim.plugins.minuet = {
    enable = nixvim.mistral.code or false;
    luaConfig.pre = ''
      if (vim.env.MISTRAL_API_KEY or "") ~= "" then
    '';
    luaConfig.post = ''
      end
    '';
    settings = {
      provider = "codestral";
      n_completions = 1;
      provider_options.codestral = {
        model = "codestral-latest";
        end_point = "https://api.mistral.ai/v1/fim/completions";
        api_key = "MISTRAL_API_KEY";
        optional = {
          max_tokens = 256;
          stop = [ "\n\n" ];
        };
      };
    };
  };
}
