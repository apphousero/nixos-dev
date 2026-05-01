#!/usr/bin/env bash
# Automates updating pi.nix to a newer version of @mariozechner/pi-coding-agent.
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
  TARGET_VERSION=$(curl -s 'https://registry.npmjs.org/@mariozechner/pi-coding-agent/latest' | jq -r '.version')
fi

echo "Target version: ${TARGET_VERSION}"

# Step 2: get git commit
echo "Fetching git commit for v${TARGET_VERSION}..."
COMMIT=$(curl -s "https://registry.npmjs.org/@mariozechner/pi-coding-agent/${TARGET_VERSION}" | jq -r '.gitHead')
if [[ -z "$COMMIT" || "$COMMIT" == "null" ]]; then
  echo "ERROR: Could not resolve gitHead for version ${TARGET_VERSION}"
  exit 1
fi
echo "Git commit: ${COMMIT}"

# Step 3: get source hash
echo "Fetching source hash..."
HASH_LINE=$(nix-prefetch-url --unpack "https://github.com/badlogic/pi-mono/archive/${COMMIT}.tar.gz" 2>&1 | tail -1)
SOURCE_HASH=$(nix hash to-sri --type sha256 "$HASH_LINE" 2>/dev/null)
echo "Source hash: ${SOURCE_HASH}"

# Step 4: get npm deps hash
# Write a temp version with new source, build it (using current npmDepsHash as placeholder),
# then compute the actual hash from the resulting npmDeps store path.
echo "Building with new source to compute npm deps hash..."

CURRENT_NPM_HASH=$(grep 'npmDepsHash' "$NIX_FILE" | sed -n 's/.*"\(sha256-[A-Za-z0-9+/=]*\)".*/\1/p')

TMP_NIX=$(mktemp)
cp "$NIX_FILE" "$TMP_NIX"

# Update fields in the temp file using Python for reliable string replacement
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
" "$TMP_NIX" "$TARGET_VERSION" "$COMMIT" "$SOURCE_HASH" "$CURRENT_NPM_HASH"

# Build the npmDeps derivation to compute its hash.
# The current npmDepsHash is almost certainly wrong for the new source, so the
# build will fail with a hash-mismatch error that contains the correct hash.
echo "  (this may take a while if deps are not cached)..."
NIX_OUT=$(nix-build -E "
  let
    pkgs = import <nixpkgs> {};
    pkg = pkgs.callPackage ${TMP_NIX} {};
  in
  pkg.npmDeps
" --no-link 2>&1 || true)

# First check if the build succeeded (hash was already correct)
NPM_DEPS_PATH=$(echo "$NIX_OUT" | grep '^/nix/store/' | head -1)

if [[ -n "$NPM_DEPS_PATH" ]] && [[ -d "$NPM_DEPS_PATH" ]]; then
  NPM_DEPS_HASH=$(nix hash path "$NPM_DEPS_PATH" 2>/dev/null)
  echo "Npm deps hash: ${NPM_DEPS_HASH}"
else
  # Extract the correct hash from the "got hash:" line in the hash-mismatch error
  # Nix fixed-output derivations (like npmDeps) report mismatches as:
  #   "got hash: sha256-..."
  NPM_DEPS_HASH=$(echo "$NIX_OUT" | grep -oP 'got hash:\s+\K\S+' | head -1)
  # Fallback: try "actual:" pattern used in some Nix versions
  if [[ -z "$NPM_DEPS_HASH" ]]; then
    NPM_DEPS_HASH=$(echo "$NIX_OUT" | grep -oP 'actual:\s+\K\S+' | head -1)
  fi
  if [[ -n "$NPM_DEPS_HASH" ]]; then
    echo "Npm deps hash: ${NPM_DEPS_HASH}"
  else
    echo "WARNING: Could not compute npm deps hash from build output."
    echo "Build output was:"
    echo "$NIX_OUT" | tail -20
    echo ""
    echo "Using placeholder — you may need to update npmDepsHash manually."
    NPM_DEPS_HASH=""
  fi
fi

# Cleanup temp nix file
rm -f "$TMP_NIX"

# Step 5: check preBuild patch compatibility
echo ""
echo "Checking preBuild patch compatibility..."
BUILD_SCRIPT=$(curl -sL "https://raw.githubusercontent.com/badlogic/pi-mono/${COMMIT}/packages/ai/package.json" | grep '"build":')
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
