{
  config,
  pkgs,
  lib,
  copilot ? {
    chat = false;
    code = false;
  },
  ...
}:

let
  # Helper to check if a package is in home.packages (mirrors the NixOS hasPackage helper)
  hasPackage =
    pkg: builtins.any (p: p.pname or p.name or "" == pkg) config.home.packages;
  hasDotnetSdk = hasPackage "dotnet" || hasPackage "dotnet-sdk" || hasPackage "dotnet-sdk_8";
  hasNodejs = hasPackage "nodejs";
  hasPython = hasPackage "python3";
  hasGo = hasPackage "go";
  hasJava = hasPackage "openjdk" || hasPackage "jdk";

  remoteConf = builtins.toFile "tmux.remote.conf" ''
    unbind C-q
    unbind q
    set-option -g prefix C-a
    bind a send-prefix
    bind C-a last-window
    set-option -g status-position top
    set -g @catppuccin_flavor "mocha"
  '';
in
{
  imports = [
    # Nixvim sub-modules that work as-is (no NixOS-specific references)
    ./nixvim/colorschemes.nix
    ./nixvim/globals.nix
    ./nixvim/keymaps.nix
    ./nixvim/opts.nix
    ./nixvim/mini
    # Plugin sub-modules that work as-is
    ./nixvim/plugins/cmp.nix
    ./nixvim/plugins/copilot.nix
    ./nixvim/plugins/telescope.nix
    ./nixvim/plugins/treesitter.nix
  ];

  # Copilot disabled by default
  _module.args.copilot = lib.mkDefault {
    chat = false;
    code = false;
  };

  # ── Packages (mirrors base.nix environment.systemPackages) ──────────────
  home.packages = with pkgs; [
    ast-grep
    atac
    atuin
    bat
    btop
    coreutils
    curl
    dive
    dos2unix
    duf
    dust
    eza
    fastfetch
    fd
    file
    fh
    fzf
    gcc
    git
    gnumake
    htop
    jq
    lazygit
    lazyjournal
    lsof
    mc
    nano
    ncdu
    nerdfetch
    neofetch
    nitch
    nix-tree
    nix-output-monitor
    nushell
    openssl
    python3
    superfile
    ripgrep
    rsync
    age
    sops
    ssh-to-age
    tldr
    tree
    tmux
    unzip
    wget
    yazi
    zellij
    zip
    zoxide
    zsh
  ];

  # ── Environment variables ───────────────────────────────────────────────
  home.sessionVariables = {
    VISUAL = "nvim";
    EDITOR = "nvim";
    MC_SKIN = "dark";
  };

  # ── Git ─────────────────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    extraConfig = {
      init.defaultBranch = "master";
      core.autocrlf = false;
    };
  };

  # ── ZSH (adapted from modules/zsh for home-manager) ────────────────────
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      la = "eza -la";
      l = "la";
      ld = "lazydocker";
      lg = "lazygit";
      lj = "lazyjournal";
      gs = "git status";
      node24 = "nix shell nixpkgs#nodejs_24";
      node22 = "nix shell nixpkgs#nodejs_22";
      node20 = "nix shell nixpkgs#nodejs_20";
      node18 = "nix shell nixpkgs#nodejs_18";
      myvim = "nvim .";
      mn = "myvim";
      rtty = "clear; exec $SHELL";
      n = "nitch";
      tk = "tmux kill-session";
    };

    initExtra = ''
      # Load zinit
      if [[ ! -f ~/.zinit/bin/zinit.zsh ]]; then
        mkdir -p ~/.zinit
        git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin
      fi
      source ~/.zinit/bin/zinit.zsh

      # Plugins from ThePrimeagen's setup
      zinit light zsh-users/zsh-autosuggestions
      zinit light zsh-users/zsh-syntax-highlighting
      zinit light zsh-users/zsh-completions
      zinit light djui/alias-tips
      zinit light agkozak/zsh-z

      # Prompt (powerlevel10k, as in video)
      zinit light romkatv/powerlevel10k
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      eval "$(atuin init zsh)"

      # Disable flow control so CTRL+Q, CTRL+S can be used for bindings (tmux in ssh)
      stty -ixon
      if [[ -z $TMUX ]]; then
        nitch
      fi

      shhh() {
        if [[ -n "$SSH_CONNECTION" || -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
          echo "Cannot shutdown - you're in an SSH session!"
          echo "Disconnect first or use 'sudo shutdown now' if you really mean it."
        else
          sudo shutdown now
        fi
      }
    '';
  };

  # ── Tmux (adapted from modules/tmux for home-manager) ──────────────────
  programs.tmux = {
    enable = true;
    shortcut = "q";
    escapeTime = 10;
    keyMode = "vi";
    terminal = "tmux-256color";
    historyLimit = 10000;

    plugins = with pkgs.tmuxPlugins; [
      catppuccin
      continuum
      copycat
      resurrect
      sensible
      tmux-fzf
      tmux-thumbs
      fzf-tmux-url
      urlview
      yank
    ];

    extraConfig = with pkgs.tmuxPlugins; ''
      # Window naming settings
      set-option -g automatic-rename off
      set-option -g allow-rename off

      bind-key R run-shell ' \
        tmux source-file ~/.config/tmux/tmux.conf > /dev/null; \
        tmux display-message "sourced tmux.conf"'

      if -F "$SSH_CONNECTION" "source-file '${remoteConf}'"

      set-option -g status-right ' #{prefix_highlight} "#{=21:pane_title}" %H:%M %d-%b-%y'
      set-option -g status-left-length 40
      run-shell '${prefix-highlight}/share/tmux-plugins/prefix-highlight/prefix_highlight.tmux'

      # Be faster switching windows
      bind C-n next-window
      bind C-p previous-window

      # Switch between sessions
      bind C-j switch-client -n
      bind C-k switch-client -p
      unbind C-b
      bind C-b previous-window

      # lazygit popup window
      unbind C-g
      bind C-g display-popup -w 90% -h 90% -d '#{pane_current_path}' -E 'lazygit'
      unbind C-x
      bind -n C-x display-popup -w 90% -h 90% -d '#{pane_current_path}' -E 'bash'
      unbind C-t
      bind -n C-t display-popup -w 90% -h 90% -d '#{pane_current_path}' -E 'zsh'

      # Refresh shell
      unbind l
      unbind C-l
      bind l send-keys 'clear' Enter
      bind C-l send-keys 'clear' Enter

      # Send the bracketed paste mode when pasting
      unbind y
      bind y paste-buffer -p

      set-option -g set-titles on

      bind C-y run-shell ' \
        ${pkgs.tmux}/bin/tmux show-buffer > /dev/null 2>&1 \
        && ${pkgs.tmux}/bin/tmux show-buffer | ${pkgs.xsel}/bin/xsel -ib'

      # Force true colors
      set-option -ga terminal-overrides ",*:Tc"

      set-option -g mouse on
      set-option -g focus-events on

      # Stay in same directory when split
      bind % split-window -h -c "#{pane_current_path}"
      bind '"' split-window -v -c "#{pane_current_path}"

      set-option -g base-index 1
      set-option -g renumber-windows on

      # Catppuccin theme configuration
      set -g @catppuccin_flavor "frappe"
      set -g @catppuccin_window_number "#I"
      set -g @catppuccin_window_text "#W"
      set -g @catppuccin_window_current_number "#I"
      set -g @catppuccin_window_current_text "#W"

      # Resurrect
      set -g @resurrect-strategy-nvim 'session'
      set -g @resurrect-processes 'false'
      set -g @resurrect-capture-pane-contents 'on'

      set -g @fzf-url-fzf-options '-p 60%,30% --prompt="[open]" --border-label=" Open URL "'
      set -g @fzf-url-history-limit '2000'

      # Continuum restore
      set -g @continuum-restore 'off'
      set -g @continuum-save-interval '0'
    '';
  };

  # ── Nixvim (adapted: uses config.home.packages instead of config.environment.systemPackages) ──
  programs.nixvim = {
    enable = true;
    autoCmd = [
      {
        event = [ "FileType" ];
        pattern = [
          "cs"
          "csproj"
        ];
        command = "setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab";
      }
      {
        event = [ "FileType" ];
        pattern = [ "nix" ];
        command = "setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab";
      }
    ];
    extraConfigVim = ''
      command! W w
    '';
    extraPackages =
      with pkgs;
      [
        gcc
        nil
      ]
      ++ lib.lists.optionals hasDotnetSdk [
        dotnet-sdk
        netcoredbg
        omnisharp-roslyn
      ]
      ++ lib.lists.optionals hasNodejs [
        nodejs
        nodePackages.prettier
        nodePackages.vscode-langservers-extracted
        vscode-js-debug
      ];

    # DAP config for .NET (adapted from lua.nix)
    extraConfigLua = lib.mkIf hasDotnetSdk ''
      local dap = require('dap')
      dap.adapters.coreclr = {
          type = 'executable',
          command = '${pkgs.netcoredbg}/bin/netcoredbg',
          args = { '--interpreter=vscode' }
        }
        dap.configurations.cs = {
          {
            type = "coreclr",
            name = "launch - netcoredbg",
            request = "launch",
            program = function()
              return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/', 'file')
              end,
          },
        }
    '';

    # Plugin settings from plugins/default.nix (inlined to avoid importing lsp.nix transitively)
    plugins = {
      dap.enable = true;
      dap-ui.enable = true;
      nvim-tree = {
        enable = true;
        settings = {
          auto_reload_on_write = true;
          disable_netrw = false;
          hijack_cursor = false;
          hijack_netrw = true;
          hijack_unnamed_buffer_when_opening = true;
          view.width = 50;
        };
      };
      undotree = {
        enable = true;
        autoLoad = true;
      };
      web-devicons.enable = true;

      # LSP (adapted from plugins/lsp.nix)
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

    # LSP servers (adapted from plugins/lsp.nix)
    lsp = {
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
        htmx.enable = lib.mkDefault hasNodejs;
        java_language_server.enable = lib.mkDefault hasJava;
        jsonls.enable = true;
        lua_ls.enable = true;
        marksman.enable = true;
        nil_ls = {
          enable = true;
          config.autoArchive = true;
        };
        omnisharp = {
          enable = lib.mkDefault hasDotnetSdk;
          config = {
            FormattingOptions = {
              EnableEditorConfigSupport = true;
              OrganizImports = true;
            };
            RoslynExtensionsOptions = {
              EnableAnalyzersSupport = true;
              EnableImportCompletion = true;
              AnalyzeOpenDocumentsOnly = false;
            };
            Sdk.IncludePrereleases = true;
            EnableRoslynAnalyzers = true;
            EnableSemanticHighlighting = true;
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
        ts_ls.enable = lib.mkDefault hasNodejs;
        yamlls.enable = true;
      };
    };
  };

  # ── Yazi ────────────────────────────────────────────────────────────────
  programs.yazi = {
    enable = true;
    settings = {
      yazi = {
        show_hidden = true;
        show_symlink = true;
      };
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
