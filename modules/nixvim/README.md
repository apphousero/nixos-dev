# Nixvim Configuration

This directory contains the Neovim configuration using nixvim.

## Custom Keymaps

### General Keymaps (keymaps.nix)

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| Insert | `<C-c>` | `<Esc>` | Set CTRL+C the same as Escape action |
| Normal | `<Space>` | `<nop>` | Remove `<Space>` key map (used as leader) |
| Normal | `<leader>q` | `:bdelete\|b#` | Closes current buffer |
| Normal | `<leader>pv` | `:Ex` | Open NetRW |
| Normal | `<leader>u` | `:UndotreeToggle` | Undotree toggle |
| Normal | `<leader>gs` | `:Git` | Open Fugitive git status |
| Visual | `J` | `:m '>+1<CR>gv=gv` | Moves text selection down |
| Visual | `K` | `:m '<-2<CR>gv=gv` | Moves text selection up |
| Visual (x) | `<leader>p` | `"_dP` | Delete and paste from the black hole register |
| Normal/Visual | `<leader>y` | `"+y` | Yank to system clipboard |
| Normal | `<leader>Y` | `"+Y` | Yank entire line to system clipboard |
| Normal/Visual | `<leader>d` | `"_d` | Delete into the black hole register |
| Normal | `<leader>f` | `vim.lsp.buf.format` | Format buffer with LSP |
| Normal | `<leader>F` | (function) | Open default file from current directory |
| Normal | `<leader>w` | `MiniFiles.open` | Open mini.files |
| Normal | `<leader>e` | `:NvimTreeToggle` | Toggle NvimTree |
| Normal | `<C-k>` | `:cnext<CR>zz` | Navigate to next quickfix item |
| Normal | `<C-j>` | `:cprev<CR>zz` | Navigate to previous quickfix item |
| Normal | `<leader>n` | `:set list!` | Toggle display of white spaces |
| Normal | `<leader>l` | `0v$y` | Copy current line |
| Normal | `<leader>b` | `:b#` | Previous buffer |

### LSP Keymaps (plugins/lsp.nix)

| Key | Action | Description |
|-----|--------|-------------|
| `gd` | `telescope.lsp_definitions` | Go to definition (via Telescope) |
| `gD` | `lsp.buf.references` | Find all references |
| `gt` | `lsp.buf.type_definition` | Go to type definition |
| `gi` | `lsp.buf.implementation` | Go to implementation |
| `<leader>K` | `:Lspsaga hover_doc` | Show hover documentation |
| `<leader>k` | `vim.diagnostic.jump({count=-1})` | Jump to previous diagnostic |
| `<leader>j` | `vim.diagnostic.jump({count=1})` | Jump to next diagnostic |
| `<leader>lx` | `:LspStop` | Stop LSP server |
| `<leader>ls` | `:LspStart` | Start LSP server |
| `<leader>lr` | `:LspRestart` | Restart LSP server |

### Enabled LSP Servers

| Server | Language | Condition |
|--------|----------|-----------|
| bashls | Bash/Shell | Always |
| clangd | C/C++ | Always |
| cssls | CSS | Node.js installed |
| dockerls | Docker | Always |
| eslint | JavaScript/TypeScript | Node.js installed |
| gopls | Go | Go installed |
| html | HTML | Node.js installed |
| htmx | HTMX | Node.js installed |
| java_language_server | Java | JDK installed |
| jsonls | JSON | Always |
| lua_ls | Lua | Always |
| marksman | Markdown | Always |
| nil_ls | Nix | Always |
| omnisharp | C# | .NET SDK installed |
| pylsp | Python | Python installed |
| tsserver | TypeScript/JavaScript | Node.js installed |
| yamlls | YAML | Always |

---

## Vim Cheatsheet

### Global Commands

| Command | Description |
|---------|-------------|
| `:h[elp] keyword` | Access help documentation |
| `:sav[eas] file` | Save with new filename |
| `:clo[se]` | Close current pane |
| `:ter[minal]` | Launch terminal window |
| `K` | Display man page for word under cursor |

### Cursor Movement

#### Basic Navigation

| Key | Description |
|-----|-------------|
| `h` `j` `k` `l` | Move left, down, up, right |
| `gj` `gk` | Navigate wrapped lines vertically |
| `H` `M` `L` | Jump to top, middle, bottom of screen |

#### Word Navigation

| Key | Description |
|-----|-------------|
| `w` `W` | Next word start (W ignores punctuation) |
| `e` `E` | Next word end (E ignores punctuation) |
| `b` `B` | Previous word start |
| `ge` `gE` | Previous word end |

#### Line Navigation

| Key | Description |
|-----|-------------|
| `0` | Line start |
| `^` | First non-blank character |
| `$` | Line end |
| `g_` | Last non-blank character |

#### Document Navigation

| Key | Description |
|-----|-------------|
| `gg` | First line |
| `G` | Last line |
| `5gg` or `5G` | Jump to line 5 |
| `gd` `gD` | Local/global declaration |

#### Character Jumping

| Key | Description |
|-----|-------------|
| `fx` | Jump to next occurrence of x |
| `Fx` | Jump to previous occurrence of x |
| `tx` | Jump before next occurrence of x |
| `Tx` | Jump after previous occurrence of x |
| `;` `,` | Repeat f/t/F/T forward/backward |
| `%` | Matching bracket/brace |

#### Paragraph/Block Navigation

| Key | Description |
|-----|-------------|
| `{` `}` | Previous/next paragraph or code block |

#### Screen Positioning

| Key | Description |
|-----|-------------|
| `zz` `zt` `zb` | Center, top, bottom cursor positioning |
| `Ctrl+e` `Ctrl+y` | Scroll without cursor movement |
| `Ctrl+b` `Ctrl+f` | Page up/down |
| `Ctrl+d` `Ctrl+u` | Half-page down/up |

### Insert Mode

#### Entering Insert Mode

| Key | Description |
|-----|-------------|
| `i` `I` | Insert before cursor / at line start |
| `a` `A` | Append after cursor / at line end |
| `o` `O` | New line below / above |
| `ea` | Insert at word end |

#### Editing During Insert

| Key | Description |
|-----|-------------|
| `Ctrl+h` | Delete character before cursor |
| `Ctrl+w` | Delete word before cursor |
| `Ctrl+j` | Line break at cursor |
| `Ctrl+t` `Ctrl+d` | Indent/de-indent |
| `Ctrl+n` `Ctrl+p` | Next/previous auto-complete |
| `Ctrl+rx` | Insert register x contents |
| `Ctrl+ox` | Temporary normal mode command |
| `Esc` or `Ctrl+c` | Exit insert mode |

### Editing

#### Character/Text Replacement

| Key | Description |
|-----|-------------|
| `r` | Replace single character |
| `R` | Replace multiple characters (replace mode) |
| `s` `S` | Delete and substitute character / line |
| `cc` `C` | Replace entire line / to line end |
| `ciw` `cw` `ce` | Replace word / to word end |

#### Line Operations

| Key | Description |
|-----|-------------|
| `J` `gJ` | Join lines (with/without space) |
| `gwip` | Reflow paragraph |
| `g~` `gu` `gU` | Toggle case / lowercase / uppercase |

#### Undo/Redo

| Key | Description |
|-----|-------------|
| `u` | Undo |
| `U` | Restore last changed line |
| `Ctrl+r` | Redo |
| `.` | Repeat last command |

#### Transposition

| Key | Description |
|-----|-------------|
| `xp` | Swap two characters |

### Visual Mode (Text Marking)

#### Selection Types

| Key | Description |
|-----|-------------|
| `v` | Character-wise selection |
| `V` | Line-wise selection |
| `Ctrl+v` | Block selection |
| `o` `O` | Switch/corner selection endpoints |

#### Text Objects

| Key | Description |
|-----|-------------|
| `aw` `iw` | A word / inner word |
| `ab` `ib` | A block () / inner block () |
| `aB` `iB` | A block {} / inner block {} |
| `at` `it` | A tag block / inner tag block |

#### Visual Commands

| Key | Description |
|-----|-------------|
| `>` `<` | Shift right/left |
| `y` `d` | Yank/delete marked text |
| `~` `u` `U` | Toggle/lowercase/uppercase case |
| `Esc` or `Ctrl+c` | Exit visual mode |

### Registers

#### Usage

| Command | Description |
|---------|-------------|
| `:reg[isters]` | Show register contents |
| `"xy` | Yank into register x |
| `"xp` | Paste from register x |
| `"+y` `"+p` | System clipboard yank/paste |

#### Special Registers

| Register | Description |
|----------|-------------|
| `0` | Last yank |
| `"` | Last delete/yank (unnamed) |
| `%` `#` | Current/alternate filename |
| `*` `+` | Clipboard contents |
| `/` `:` `.` | Last search/command/inserted text |

### Marks and Positions

| Command | Description |
|---------|-------------|
| `:marks` | List all marks |
| `ma` | Set mark a |
| `` `a `` | Jump to mark a position |
| `` `0 `` | Jump to position in last file edited |
| `` `. `` | Jump to last change |
| `` `` `` | Jump to last jump position |

#### Jump Lists

| Command | Description |
|---------|-------------|
| `:ju[mps]` | Show jump history |
| `Ctrl+i` `Ctrl+o` | Newer/older jump position |
| `Ctrl+]` | Jump to tag under cursor |

#### Change Lists

| Command | Description |
|---------|-------------|
| `:changes` | Show change history |
| `g;` `g,` | Older/newer change position |

### Macros

| Key | Description |
|-----|-------------|
| `qa` | Record macro a |
| `q` | Stop recording |
| `@a` | Execute macro a |
| `@@` | Rerun last macro |

### Cut and Paste

#### Yanking (Copy)

| Key | Description |
|-----|-------------|
| `yy` `2yy` | Copy line(s) |
| `yw` `yiw` `yaw` | Copy word variants |
| `y$` `Y` | Copy to line end |

#### Pasting

| Key | Description |
|-----|-------------|
| `p` `P` | Paste after / before cursor |
| `gp` `gP` | Paste and position cursor after |

#### Deleting (Cut)

| Key | Description |
|-----|-------------|
| `dd` `2dd` | Delete line(s) |
| `dw` `diw` `daw` | Delete word variants |
| `d$` `D` | Delete to line end |
| `x` | Delete character |
| `:3,5d` | Delete lines 3-5 |
| `:g/{pattern}/d` | Delete matching lines |

### Indentation

#### Manual Indentation

| Key | Description |
|-----|-------------|
| `>>` `<<` | Indent/de-indent line |
| `>%` `<%` | Indent/de-indent block |
| `>ib` `>at` | Indent inner block / tag block |

#### Auto-Indentation

| Key | Description |
|-----|-------------|
| `3==` | Re-indent 3 lines |
| `=%` `=iB` | Re-indent block / inner block |
| `gg=G` | Re-indent entire file |
| `]p` | Paste with adjusted indent |

### Search and Replace

#### Search Operations

| Command | Description |
|---------|-------------|
| `/pattern` | Search forward |
| `?pattern` | Search backward |
| `\vpattern` | "Very magic" pattern (regex) |
| `n` `N` | Repeat in same / opposite direction |
| `:noh[lsearch]` | Remove search highlighting |

#### Replace Operations

| Command | Description |
|---------|-------------|
| `:%s/old/new/g` | Replace all occurrences |
| `:%s/old/new/gc` | Replace with confirmation |

#### Multi-File Search

| Command | Description |
|---------|-------------|
| `:vim[grep] /pattern/ {file}` | Search across files |
| `:cn[ext]` `:cp[revious]` | Navigate matches |
| `:cope[n]` `:ccl[ose]` | Open/close results window |

### Tabs

| Command | Description |
|---------|-------------|
| `:tabnew {file}` | Open file in new tab |
| `Ctrl+wT` | Move split to own tab |
| `gt` `gT` | Next/previous tab |
| `#gt` | Jump to tab number |
| `:tabm[ove] #` | Move tab to position |
| `:tabc[lose]` | Close current tab |
| `:tabo[nly]` | Close other tabs |
| `:tabdo command` | Execute command on all tabs |

### Working with Multiple Files/Buffers

#### Buffer Management

| Command | Description |
|---------|-------------|
| `:e[dit] file` | Edit file in new buffer |
| `:bn[ext]` `:bp[revious]` | Navigate buffers |
| `:bd[elete]` | Delete buffer |
| `:b[uffer]#` or `:b file` | Go to specific buffer |
| `:ls` or `:buffers` | List open buffers |

#### Split Windows

| Command | Description |
|---------|-------------|
| `:sp[lit]` `:vs[plit]` | Horizontal/vertical split |
| `Ctrl+ws` `Ctrl+wv` | Split horizontal/vertical |
| `Ctrl+ww` | Switch windows |
| `Ctrl+wq` | Quit window |
| `Ctrl+wx` | Exchange windows |
| `Ctrl+w=` | Equalize window sizes |
| `Ctrl+wh/l/j/k` | Navigate windows left/right/down/up |
| `Ctrl+wH/L/J/K` | Move window to edge |

### Diff Mode

#### Fold Operations

| Key | Description |
|-----|-------------|
| `zf` | Create fold |
| `zd` | Delete fold |
| `za` `zo` `zc` | Toggle/open/close fold |
| `zr` `zm` | Open/close all folds one level |
| `zi` | Toggle fold functionality |

#### Diff Navigation

| Command | Description |
|---------|-------------|
| `]c` `[c` | Next/previous change |
| `do` or `:diffg[et]` | Obtain difference |
| `dp` or `:diffpu[t]` | Put difference |
| `:diffthis` | Enable diff for window |
| `:dif[fupdate]` | Refresh differences |
| `:diffo[ff]` | Disable diff mode |

### Exiting

| Command | Description |
|---------|-------------|
| `:w` | Save without exiting |
| `:w !sudo tee %` | Save with sudo |
| `:wq` or `:x` or `ZZ` | Save and exit |
| `:q` | Exit (fails if unsaved) |
| `:q!` or `ZQ` | Force exit without saving |
| `:wqa` | Save and exit all tabs |

---

*Based on [vim.rtorr.com](https://vim.rtorr.com) and custom nixvim configuration.*
