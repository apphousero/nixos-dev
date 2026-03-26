{
  config,
  isNixOS,
  pkgs,
  ...
}:
let
  # Thanks: https://github.com/DanielFGray/dotfiles/blob/master/tmux.remote.conf
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

    extraConfig =
      with config.theme;
      with pkgs.tmuxPlugins;
      ''
        # Window naming settings
        set-option -g allow-rename off
        set-window-option -g automatic-rename off

        bind-key R run-shell ' \
          tmux source-file ${
            if isNixOS then "/etc/tmux.conf" else "~/.config/tmux/tmux.conf"
          } > /dev/null; \
          tmux display-message "sourced ${
            if isNixOS then "/etc/tmux.conf" else "~/.config/tmux/tmux.conf"
          }"'

        # Local prefix bindings (shortcut is "q" -> C-q)
        bind q send-prefix
        bind C-q last-window

        if-shell 'test -n "$SSH_CLIENT" || test -n "$SSH_TTY" || test -n "$SSH_CONNECTION"' "source-file '${remoteConf}'"

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

        # Enable OSC 52 clipboard passthrough (allows copy over SSH via terminal)
        set-option -g set-clipboard on

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
        set -g @resurrect-processes 'false'

        set -g @fzf-url-fzf-options '-p 60%,30% --prompt="[open]" --border-label=" Open URL "'
        set -g @fzf-url-history-limit '2000'

        # Continuum restore
        set -g @continuum-restore 'off'
        set -g @continuum-save-interval '0'
      '';
  };
}
