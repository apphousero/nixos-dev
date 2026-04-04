{
  nixvim,
  ...
}:
{
  programs.nixvim.plugins = {
    copilot-lua = {
      enable = nixvim.copilot.code or nixvim.copilot.chat;
    };
    copilot-cmp = {
      enable = nixvim.copilot.code;
    };
    copilot-chat = {
      enable = nixvim.copilot.chat;
    };
  };
}
