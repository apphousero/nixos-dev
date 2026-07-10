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

set -euo pipefail

REPO="agentclientprotocol/claude-agent-acp"
NPM_PKG="@agentclientprotocol/claude-agent-acp"

DRY_RUN=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    *) TARGET_VERSION="$1"; shift ;;
  esac
done

NIX_FILE="${CLAUDE_AGENT_ACP_NIX_FILE:-$(dirname "$0")/claude-agent-acp.nix}"

if [[ -z "${TARGET_VERSION:-}" ]]; then
  echo "Fetching latest version..."
  TARGET_VERSION=$(curl -s "https://registry.npmjs.org/${NPM_PKG}/latest" | jq -r '.version')
fi

echo "Target version: ${TARGET_VERSION}"
TAG="v${TARGET_VERSION}"

# Step 2: get source hash from the git tag tarball
echo "Fetching source hash..."
HASH_LINE=$(nix-prefetch-url --unpack "https://github.com/${REPO}/archive/refs/tags/${TAG}.tar.gz" 2>&1 | tail -1)
SOURCE_HASH=$(nix hash to-sri --type sha256 "$HASH_LINE" 2>/dev/null)
echo "Source hash: ${SOURCE_HASH}"

# Step 3: get npm deps hash
# Fetch the repo's package-lock.json at this tag and feed it to
# `prefetch-npm-deps`, the same tool buildNpmPackage uses internally.
echo "Computing npm deps hash..."

TMP_LOCK=$(mktemp --suffix=-package-lock.json)
trap 'rm -f "$TMP_LOCK"' EXIT

LOCK_URL="https://raw.githubusercontent.com/${REPO}/${TAG}/package-lock.json"
HTTP_CODE=$(curl -sL -o "$TMP_LOCK" -w '%{http_code}' "$LOCK_URL")
if [[ "$HTTP_CODE" != "200" ]]; then
  echo "ERROR: Could not fetch ${LOCK_URL} (HTTP ${HTTP_CODE})"
  echo "Attempting to compute npm deps hash from npm tarball..."
  TMP_TARBALL=$(mktemp --suffix=.tar.gz)
  curl -sL "https://registry.npmjs.org/${NPM_PKG}/-/claude-agent-acp-${TARGET_VERSION}.tgz" -o "$TMP_TARBALL"
  NPM_DEPS_HASH=$(nix run --quiet nixpkgs#prefetch-npm-deps -- "$TMP_TARBALL" 2>/dev/null || true)
  rm -f "$TMP_TARBALL"
else
  NPM_DEPS_HASH=$(nix run --quiet nixpkgs#prefetch-npm-deps -- "$TMP_LOCK" 2>/dev/null || true)
fi
if [[ -z "$NPM_DEPS_HASH" || "$NPM_DEPS_HASH" != sha256-* ]]; then
  echo "ERROR: prefetch-npm-deps did not return a valid SRI hash."
  echo "Output was: ${NPM_DEPS_HASH:-<empty>}"
  NPM_DEPS_HASH=""
else
  echo "Npm deps hash: ${NPM_DEPS_HASH}"
fi

# Summary & apply
echo ""
echo "=== Summary ==="
echo "  version:     ${TARGET_VERSION}"
echo "  rev:         ${TAG}"
echo "  sourceHash:  ${SOURCE_HASH}"
if [[ -n "$NPM_DEPS_HASH" ]]; then
  echo "  npmDepsHash: ${NPM_DEPS_HASH}"
else
  echo "  npmDepsHash: (update manually)"
fi

if $DRY_RUN; then
  echo ""
  echo "Dry run — not writing ${NIX_FILE}"
else
  if [[ -z "$NPM_DEPS_HASH" ]]; then
    echo ""
    echo "ERROR: npmDepsHash extraction failed — refusing to write ${NIX_FILE}."
    echo "Re-run with --dry-run to inspect, or update npmDepsHash manually."
    exit 1
  fi
  echo ""
  echo "Updating ${NIX_FILE}..."
  python3 -c "
import re, sys

with open(sys.argv[1]) as f:
    content = f.read()

content = re.sub(r'(^  version = \")([^\"]+)(\")', lambda m: m.group(1) + sys.argv[2] + m.group(3), content, count=1, flags=re.MULTILINE)
content = re.sub(r'(^    hash = \")([^\"]+)(\")', lambda m: m.group(1) + sys.argv[3] + m.group(3), content, count=1, flags=re.MULTILINE)
content = re.sub(r'(^  npmDepsHash = \")([^\"]+)(\")', lambda m: m.group(1) + sys.argv[4] + m.group(3), content, count=1, flags=re.MULTILINE)

with open(sys.argv[1], 'w') as f:
    f.write(content)
" "$NIX_FILE" "$TARGET_VERSION" "$SOURCE_HASH" "$NPM_DEPS_HASH"
  echo "Done. Verify, test, and commit."
fi
