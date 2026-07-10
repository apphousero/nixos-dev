#!/usr/bin/env bash
# Automates updating pi.nix to a newer version of @earendil-works/pi-coding-agent.
#
# Usage:
#   ./packages/update-pi.sh                     # interactively pick latest version
#   ./packages/update-pi.sh 0.71.1              # update to a specific version
#   ./packages/update-pi.sh --dry-run 0.71.1    # show what would change without writing
#
# Environment:
#   PI_NIX_FILE  Path to pi.nix (default: ./packages/pi.nix)
#
# See update-npm-package.sh for the underlying generic updater.

set -euo pipefail

export NPM_PKG="@earendil-works/pi-coding-agent"
export REPO="earendil-works/pi-mono"
export NIX_FILE="${PI_NIX_FILE:-$(dirname "$0")/pi.nix}"
export REV_STRATEGY="commit"
export NPM_TARBALL_FALLBACK="false"
export PREBUILD_PKG_JSON="packages/ai/package.json"

exec "$(dirname "$0")/update-npm-package.sh" "$@"
