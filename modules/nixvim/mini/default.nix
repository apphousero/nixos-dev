{ ... }:
{
  imports = [
    ./clue.nix
    ./starter.nix
  ];
  programs.nixvim.plugins.mini = {
    enable = true;
    autoLoad = true;
    mockDevIcons = false;
    modules = {
      ai = { };
      align = { };
      basics = { };
      bracketed = { };
      bufremove = { };
      comment = { };
      cursorword = { };
      colors = { };
      comment = { };
      #completion = { };
      diff = {
        view = {
          style = "number";
        };
      };
      doc = { };
      extra = { };
      files = {
        options = {
          use_as_default_explorer = false;
        };
      };
      fuzzy = { };
      git = { };
      icons = {
        style = "glyph";
        default = { };
        directory = { };
        extension = { };
        file = { };
        filetype = { };
        lsp = { };
        os = { };
      };
      indentscope = { };
      jump = { };
      jump2d = { };
      map = { };
      misc = { };
      move = { };
      notify = { };
      operators = { };
      # pairs = { };
      pick = { };
      snippets = { };
      splitjoin = { };
      surround = { };
      statusline = {
        use_icons = true;
        set_vim_settings = true;
      };
      tabline = {
        show_icons = true;
        format = null;
        set_vim_settings = true;
        tabpage_selection = true;
      };
      test = { };
      trailspace = { };
      visits = { };
    };
  };
}
