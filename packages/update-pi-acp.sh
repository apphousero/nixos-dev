#!/usr/bin/env bash
# Automates updating pi-acp.nix to a newer version of svkozak/pi-acp.
#
# Usage:
#   ./packages/update-pi-acp.sh                    # interactively pick latest version
#   ./packages/update-pi-acp.sh 0.0.31             # update to a specific version
#   ./packages/update-pi-acp.sh --dry-run 0.0.31   # show what would change without writing
#
# Environment:
#   PI_ACP_NIX_FILE  Path to pi-acp.nix (default: ./packages/pi-acp.nix)
#
# See update-npm-package.sh for the underlying generic updater.

set -euo pipefail

export NPM_PKG="pi-acp"
export REPO="svkozak/pi-acp"
export NIX_FILE="${PI_ACP_NIX_FILE:-$(dirname "$0")/pi-acp.nix}"
export REV_STRATEGY="commit-from-tag"

exec "$(dirname "$0")/update-npm-package.sh" "$@"
