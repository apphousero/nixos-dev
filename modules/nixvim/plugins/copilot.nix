{
  copilot ? {
    chat = false;
    code = false;
  },
  ...
}:
{
  programs.nixvim.plugins = {
    copilot-lua = {
      enable = copilot.code or copilot.chat;
    };
    copilot-cmp = {
      enable = copilot.code;
    };
    copilot-chat = {
      enable = copilot.chat;
    };
  };
}
