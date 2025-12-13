{ ... }: {
  programs.nixvim.opts = {
    backup = false;
    colorcolumn = "120";
    cursorline = true;
    expandtab = true;
    hlsearch = false;
    #guicursor = "";
    incsearch = true;
    list = true;
    listchars = "space:·,tab:→ ,eol:↲,nbsp:␣,trail:•,extends:⟩,precedes:⟨";
    nu = true;
    number = true;
    relativenumber = true;
    scrolloff = 8;
    signcolumn = "yes";
    shiftwidth = 4;
    softtabstop = 4;
    swapfile = false;
    smartindent = true;
    tabstop = 4;
    termguicolors = true;
    undofile = true;
    updatetime = 50;
    wrap = false;
  };
}
