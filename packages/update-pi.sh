#!/usr/bin/env bash
# Automates updating pi.nix to a newer version of @earendil-works/pi-coding-agent.
#
# Usage:
#   ./packages/update-pi.sh                           # interactively pick latest version
#   ./packages/update-pi.sh 0.71.1                    # update to a specific version
#   ./packages/update-pi.sh --dry-run 0.71.1          # show what would change without writing
#
# Environment:
#   PI_NIX_FILE  Path to pi.nix (default: ./packages/pi.nix)

set -euo pipefail

DRY_RUN=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    *) TARGET_VERSION="$1"; shift ;;
  esac
done

NIX_FILE="${PI_NIX_FILE:-$(dirname "$0")/pi.nix}"

if [[ -z "${TARGET_VERSION:-}" ]]; then
  echo "Fetching latest version..."
  TARGET_VERSION=$(curl -s 'https://registry.npmjs.org/@earendil-works/pi-coding-agent/latest' | jq -r '.version')
fi

echo "Target version: ${TARGET_VERSION}"

# Step 2: get git commit
echo "Fetching git commit for v${TARGET_VERSION}..."
COMMIT=$(curl -s "https://registry.npmjs.org/@earendil-works/pi-coding-agent/${TARGET_VERSION}" | jq -r '.gitHead')
if [[ -z "$COMMIT" || "$COMMIT" == "null" ]]; then
  echo "ERROR: Could not resolve gitHead for version ${TARGET_VERSION}"
  exit 1
fi
echo "Git commit: ${COMMIT}"

# Step 3: get source hash
echo "Fetching source hash..."
HASH_LINE=$(nix-prefetch-url --unpack "https://github.com/earendil-works/pi-mono/archive/${COMMIT}.tar.gz" 2>&1 | tail -1)
SOURCE_HASH=$(nix hash to-sri --type sha256 "$HASH_LINE" 2>/dev/null)
echo "Source hash: ${SOURCE_HASH}"

# Step 4: get npm deps hash
# Fetch the repo's package-lock.json at this commit and feed it to
# `prefetch-npm-deps`, the same tool buildNpmPackage uses internally. This is
# orders of magnitude faster than a full nix-build hash-mismatch dance.
echo "Computing npm deps hash..."

TMP_LOCK=$(mktemp --suffix=-package-lock.json)
trap 'rm -f "$TMP_LOCK"' EXIT

LOCK_URL="https://raw.githubusercontent.com/earendil-works/pi-mono/${COMMIT}/package-lock.json"
HTTP_CODE=$(curl -sL -o "$TMP_LOCK" -w '%{http_code}' "$LOCK_URL")
if [[ "$HTTP_CODE" != "200" ]]; then
  echo "ERROR: Could not fetch ${LOCK_URL} (HTTP ${HTTP_CODE})"
  exit 1
fi

NPM_DEPS_HASH=$(nix run --quiet nixpkgs#prefetch-npm-deps -- "$TMP_LOCK" 2>/dev/null || true)
if [[ -z "$NPM_DEPS_HASH" || "$NPM_DEPS_HASH" != sha256-* ]]; then
  echo "ERROR: prefetch-npm-deps did not return a valid SRI hash."
  echo "Output was: ${NPM_DEPS_HASH:-<empty>}"
  NPM_DEPS_HASH=""
else
  echo "Npm deps hash: ${NPM_DEPS_HASH}"
fi

# Step 5: check preBuild patch compatibility
echo ""
echo "Checking preBuild patch compatibility..."
BUILD_SCRIPT=$(curl -sL "https://raw.githubusercontent.com/earendil-works/pi-mono/${COMMIT}/packages/ai/package.json" | grep '"build":')
echo "New build script: ${BUILD_SCRIPT}"

CURRENT_OLD=$(grep 'replace-fail' "$NIX_FILE" | head -1 | sed -n 's/.*--replace-fail "\([^"]*\)".*/\1/p')
if [[ -n "$CURRENT_OLD" && "${BUILD_SCRIPT}" != *"${CURRENT_OLD}"* ]]; then
  echo ""
  echo "⚠️  preBuild patch may need updating:"
  echo "  Old pattern:  ${CURRENT_OLD}"
  echo "  New line:     ${BUILD_SCRIPT}"
fi

# Summary & apply
echo ""
echo "=== Summary ==="
echo "  version:     ${TARGET_VERSION}"
echo "  rev:         ${COMMIT}"
echo "  hash:        ${SOURCE_HASH}"
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
" "$NIX_FILE" "$TARGET_VERSION" "$COMMIT" "$SOURCE_HASH" "$NPM_DEPS_HASH"
  echo "Done. Verify, test, and commit."
fi
