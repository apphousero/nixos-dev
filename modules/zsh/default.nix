{ ... }:

{
  # Enable and configure oh-my-zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    promptInit = ''
      # Load zinit
      if [[ ! -f ~/.zinit/bin/zinit.zsh ]]; then
        mkdir -p ~/.zinit
        git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin
      fi
      source ~/.zinit/bin/zinit.zsh

      # Plugins from ThePrimeagen’s setup
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
    '';
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
      rtty = "exec $SHELL; clear";
      n = "nitch";
      tk = "tmux kill-session";
    };
    interactiveShellInit = ''
      shhh() {
        if [[ -n "$SSH_CONNECTION" || -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
          echo "🚫 Cannot shutdown - you're in an SSH session!"
          echo "Disconnect first or use 'sudo shutdown now' if you really mean it."
        else
          sudo shutdown now
        fi
      }
    '';
  };
}
