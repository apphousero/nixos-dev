{ ... }: {
  programs.nixvim.plugins.treesitter = {
    enable = true;
    settings = {
      additional_vim_regex_highlighting = false;
      autoinstall = true;
      highlight.enable = true;
      ensure_installed = [
        "bash"
        "c"
        "c_sharp"
        "cpp"
        "css"
        "csv"
        "dockerfile"
        "git_config"
        "git_rebase"
        "gitattributes"
        "gitcommit"
        "gitignore"
        "html"
        "javascript"
        "json"
        "json5"
        "lua"
        "markdown"
        "markdown_inline"
        "mermaid"
        "nix"
        "ql"
        "python"
        "query"
        "regex"
        "rust"
        "sql"
        "ssh_config"
        "tmux"
        "tsx"
        "typescript"
        "vim"
        "vimdoc"
        "yaml"
        "zig"
        ];
    };
  };
}
