#!/usr/bin/env bash
# Automates updating claude-agent-acp.nix to a newer version of
# @agentclientprotocol/claude-agent-acp.
#
# Usage:
#   ./packages/update-claude-agent-acp.sh                    # interactively pick latest version
#   ./packages/update-claude-agent-acp.sh 0.58.1             # update to a specific version
#   ./packages/update-claude-agent-acp.sh --dry-run 0.58.1   # show what would change without writing
#
# Environment:
#   CLAUDE_AGENT_ACP_NIX_FILE  Path to claude-agent-acp.nix (default: ./packages/claude-agent-acp.nix)
#
# See update-npm-package.sh for the underlying generic updater.

set -euo pipefail

export NPM_PKG="@agentclientprotocol/claude-agent-acp"
export REPO="agentclientprotocol/claude-agent-acp"
export NIX_FILE="${CLAUDE_AGENT_ACP_NIX_FILE:-$(dirname "$0")/claude-agent-acp.nix}"
export REV_STRATEGY="commit-from-tag"

exec "$(dirname "$0")/update-npm-package.sh" "$@"
