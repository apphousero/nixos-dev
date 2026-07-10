#!/usr/bin/env bash
# Automates updating pi-acp.nix to a newer version of svkozak/pi-acp.
#
# Usage:
#   ./packages/update-pi-acp.sh                           # interactively pick latest version
#   ./packages/update-pi-acp.sh 0.0.31                    # update to a specific version
#   ./packages/update-pi-acp.sh --dry-run 0.0.31          # show what would change without writing
#
# Environment:
#   PI_ACP_NIX_FILE  Path to pi-acp.nix (default: ./packages/pi-acp.nix)

set -euo pipefail

DRY_RUN=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    *) TARGET_VERSION="$1"; shift ;;
  esac
done

NIX_FILE="${PI_ACP_NIX_FILE:-$(dirname "$0")/pi-acp.nix}"

if [[ -z "${TARGET_VERSION:-}" ]]; then
  echo "Fetching latest version..."
  TARGET_VERSION=$(curl -s 'https://registry.npmjs.org/pi-acp/latest' | jq -r '.version')
fi

echo "Target version: ${TARGET_VERSION}"

# Step 2: get git tag commit
echo "Fetching git commit for v${TARGET_VERSION}..."
TAG_INFO=$(curl -s "https://api.github.com/repos/svkozak/pi-acp/tags" | jq -r ".[] | select(.name==\"v${TARGET_VERSION}\") | .commit.sha")
if [[ -z "$TAG_INFO" || "$TAG_INFO" == "null" ]]; then
  echo "ERROR: Could not resolve git tag for version ${TARGET_VERSION}"
  echo "Checking npm metadata for gitHead..."
  COMMIT=$(curl -s "https://registry.npmjs.org/pi-acp/${TARGET_VERSION}" | jq -r '.gitHead // empty')
  if [[ -z "$COMMIT" ]]; then
    echo "Cannot determine commit — please update manually."
    exit 1
  fi
  TAG_INFO="$COMMIT"
fi
echo "Git commit: ${TAG_INFO}"

# Step 3: get source hash
echo "Fetching source hash..."
HASH_LINE=$(nix-prefetch-url --unpack "https://github.com/svkozak/pi-acp/archive/refs/tags/v${TARGET_VERSION}.tar.gz" 2>&1 | tail -1)
SOURCE_HASH=$(nix hash to-sri --type sha256 "$HASH_LINE" 2>/dev/null)
echo "Source hash: ${SOURCE_HASH}"

# Step 4: get npm deps hash
echo "Computing npm deps hash..."

TMP_LOCK=$(mktemp --suffix=-package-lock.json)
trap 'rm -f "$TMP_LOCK"' EXIT

LOCK_URL="https://raw.githubusercontent.com/svkozak/pi-acp/v${TARGET_VERSION}/package-lock.json"
HTTP_CODE=$(curl -sL -o "$TMP_LOCK" -w '%{http_code}' "$LOCK_URL")
if [[ "$HTTP_CODE" != "200" ]]; then
  echo "ERROR: Could not fetch ${LOCK_URL} (HTTP ${HTTP_CODE})"
  echo "Attempting to compute npm deps hash from npm tarball..."
  TMP_TARBALL=$(mktemp --suffix=.tar.gz)
  curl -sL "https://registry.npmjs.org/pi-acp/-/pi-acp-${TARGET_VERSION}.tgz" -o "$TMP_TARBALL"
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
echo "  rev:         v${TAG_INFO}"
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
content = re.sub(r'(^    rev = \")([^\"]+)(\")', lambda m: m.group(1) + sys.argv[3] + m.group(3), content, count=1, flags=re.MULTILINE)
content = re.sub(r'(^    hash = \")([^\"]+)(\")', lambda m: m.group(1) + sys.argv[4] + m.group(3), content, count=1, flags=re.MULTILINE)
content = re.sub(r'(^  npmDepsHash = \")([^\"]+)(\")', lambda m: m.group(1) + sys.argv[5] + m.group(3), content, count=1, flags=re.MULTILINE)

with open(sys.argv[1], 'w') as f:
    f.write(content)
" "$NIX_FILE" "$TARGET_VERSION" "v${TAG_INFO}" "$SOURCE_HASH" "$NPM_DEPS_HASH"
  echo "Done. Verify, test, and commit."
fi
