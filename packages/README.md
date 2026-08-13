# Packages

Custom Nix packages for `nixos-dev`.

## claude-agent-acp

[claude-agent-acp](https://github.com/agentclientprotocol/claude-agent-acp) - an ACP-compatible coding agent powered by the Claude Agent SDK (TypeScript).

- npm: [@agentclientprotocol/claude-agent-acp](https://www.npmjs.com/package/@agentclientprotocol/claude-agent-acp)
- Binary: `claude-agent-acp`

### Updating claude-agent-acp

```sh
# Auto-pick latest version
./packages/update-claude-agent-acp.sh

# Update to a specific version
./packages/update-claude-agent-acp.sh 0.58.1

# Preview changes without writing
./packages/update-claude-agent-acp.sh --dry-run 0.58.1
```

## aoaoe

[agent-of-agent-of-empires](https://github.com/Talador12/agent-of-agent-of-empires) - autonomous supervisor for agent-of-empires sessions (OpenCode/Claude Code).

- npm: [aoaoe](https://www.npmjs.com/package/aoaoe)
- Binaries: `aoaoe`, `aoaoe-chat`
- Runtime: shells out to `aoe`, `tmux`, `gh` (and optionally `claude`/`opencode`); `tmux`+`gh` are pinned into the wrapper, `aoe` resolves from the ambient PATH on `useAoe` hosts.

### Updating aoaoe

```sh
# Auto-pick latest version
./packages/update-aoaoe.sh

# Update to a specific version
./packages/update-aoaoe.sh 8.0.0

# Preview changes without writing
./packages/update-aoaoe.sh --dry-run 8.0.0
```

