#!/usr/bin/env bash
# Automates updating aoaoe.nix to a newer version of
# Talador12/agent-of-agent-of-empires.
#
# Usage:
#   ./packages/update-aoaoe.sh                  # interactively pick latest version
#   ./packages/update-aoaoe.sh 8.0.0            # update to a specific version
#   ./packages/update-aoaoe.sh --dry-run 8.0.0  # show what would change without writing
#
# Environment:
#   AOAOE_NIX_FILE  Path to aoaoe.nix (default: ./packages/aoaoe.nix)
#
# See update-npm-package.sh for the underlying generic updater.

set -euo pipefail

export NPM_PKG="aoaoe"
export REPO="Talador12/agent-of-agent-of-empires"
export NIX_FILE="${AOAOE_NIX_FILE:-$(dirname "$0")/aoaoe.nix}"
export REV_STRATEGY="commit-from-tag"

exec "$(dirname "$0")/update-npm-package.sh" "$@"
