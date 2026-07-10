#!/usr/bin/env bash
# Generic updater for the buildNpmPackage .nix files in this directory.
#
# Automates bumping a *.nix file to a newer version of an upstream npm package
# that is built from its GitHub source. Callers configure it via environment
# variables (see below) and pass through the version/--dry-run arguments; the
# per-package wrappers (update-pi.sh, update-pi-acp.sh, ...) are thin shims
# around this script.
#
# Usage (via a wrapper, or directly with the env vars set):
#   ./packages/update-<pkg>.sh                  # interactively pick latest version
#   ./packages/update-<pkg>.sh 1.2.3            # update to a specific version
#   ./packages/update-<pkg>.sh --dry-run 1.2.3  # show what would change without writing
#
# Required configuration (environment variables):
#   NPM_PKG    npm registry package name (e.g. "@scope/name" or "name")
#   REPO       GitHub "owner/repo" the package is built from
#   NIX_FILE   path to the .nix file to update
#
# Optional configuration:
#   REV_STRATEGY          How to resolve the rev and the ref fetched for
#                         source/lock:
#                           "tag"             rev = "v${version}", fetched by tag
#                           "commit"          rev = commit SHA from the npm
#                                             "gitHead" field, fetched by commit
#                           "commit-from-tag" rev = commit SHA resolved from the
#                                             "v${version}" tag via the GitHub
#                                             /commits API, fetched by commit
#                         Default: "tag".
#   WRITE_REV             "true" (default) substitutes the rev field in NIX_FILE;
#                         set "false" when the .nix derives rev from version
#                         (e.g. rev = "v${version}").
#   NPM_TARBALL_FALLBACK  "true" (default) falls back to the npm .tgz for the
#                         deps hash when the repo has no package-lock.json at the
#                         ref; "false" fails instead.
#   PREBUILD_PKG_JSON     repo-relative path of a package.json to diff against the
#                         --replace-fail patch in NIX_FILE (empty = skip check).

set -euo pipefail

: "${NPM_PKG:?NPM_PKG must be set}"
: "${REPO:?REPO must be set}"
: "${NIX_FILE:?NIX_FILE must be set}"

REV_STRATEGY="${REV_STRATEGY:-tag}"
WRITE_REV="${WRITE_REV:-true}"
NPM_TARBALL_FALLBACK="${NPM_TARBALL_FALLBACK:-true}"
PREBUILD_PKG_JSON="${PREBUILD_PKG_JSON:-}"

# Basename of the npm package (strip any @scope/), used for the .tgz fallback URL.
PKG_BASENAME="${NPM_PKG##*/}"

DRY_RUN=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    *) TARGET_VERSION="$1"; shift ;;
  esac
done

if [[ -z "${TARGET_VERSION:-}" ]]; then
  echo "Fetching latest version..."
  TARGET_VERSION=$(curl -s "https://registry.npmjs.org/${NPM_PKG}/latest" | jq -r '.version')
fi

echo "Target version: ${TARGET_VERSION}"
TAG="v${TARGET_VERSION}"

# Step 2: resolve the rev and the git ref to fetch source/lock from.
case "$REV_STRATEGY" in
  commit)
    echo "Fetching git commit for ${TAG}..."
    REV=$(curl -s "https://registry.npmjs.org/${NPM_PKG}/${TARGET_VERSION}" | jq -r '.gitHead // empty')
    if [[ -z "$REV" || "$REV" == "null" ]]; then
      echo "ERROR: Could not resolve gitHead for version ${TARGET_VERSION}"
      exit 1
    fi
    echo "Git commit: ${REV}"
    REF="$REV"
    SRC_URL="https://github.com/${REPO}/archive/${REF}.tar.gz"
    ;;
  commit-from-tag)
    echo "Resolving ${TAG} to a commit SHA..."
    REV=$(curl -s "https://api.github.com/repos/${REPO}/commits/${TAG}" | jq -r '.sha // empty')
    if [[ -z "$REV" || "$REV" == "null" ]]; then
      echo "ERROR: Could not resolve ${TAG} to a commit via the GitHub API"
      exit 1
    fi
    echo "Git commit: ${REV}"
    REF="$REV"
    SRC_URL="https://github.com/${REPO}/archive/${REF}.tar.gz"
    ;;
  tag)
    REV="$TAG"
    REF="$TAG"
    SRC_URL="https://github.com/${REPO}/archive/refs/tags/${TAG}.tar.gz"
    ;;
  *)
    echo "ERROR: unknown REV_STRATEGY '${REV_STRATEGY}' (expected tag|commit|commit-from-tag)"
    exit 1
    ;;
esac

# Step 3: get source hash
echo "Fetching source hash..."
HASH_LINE=$(nix-prefetch-url --unpack "$SRC_URL" 2>&1 | tail -1)
SOURCE_HASH=$(nix hash to-sri --type sha256 "$HASH_LINE" 2>/dev/null)
echo "Source hash: ${SOURCE_HASH}"

# Step 4: get npm deps hash.
# Fetch the repo's package-lock.json at this ref and feed it to
# `prefetch-npm-deps`, the same tool buildNpmPackage uses internally. This is
# orders of magnitude faster than a full nix-build hash-mismatch dance.
echo "Computing npm deps hash..."

TMP_LOCK=$(mktemp --suffix=-package-lock.json)
trap 'rm -f "$TMP_LOCK"' EXIT

LOCK_URL="https://raw.githubusercontent.com/${REPO}/${REF}/package-lock.json"
HTTP_CODE=$(curl -sL -o "$TMP_LOCK" -w '%{http_code}' "$LOCK_URL")
if [[ "$HTTP_CODE" != "200" ]]; then
  if [[ "$NPM_TARBALL_FALLBACK" == "true" ]]; then
    echo "Could not fetch ${LOCK_URL} (HTTP ${HTTP_CODE})"
    echo "Attempting to compute npm deps hash from npm tarball..."
    TMP_TARBALL=$(mktemp --suffix=.tar.gz)
    curl -sL "https://registry.npmjs.org/${NPM_PKG}/-/${PKG_BASENAME}-${TARGET_VERSION}.tgz" -o "$TMP_TARBALL"
    NPM_DEPS_HASH=$(nix run --quiet nixpkgs#prefetch-npm-deps -- "$TMP_TARBALL" 2>/dev/null || true)
    rm -f "$TMP_TARBALL"
  else
    echo "ERROR: Could not fetch ${LOCK_URL} (HTTP ${HTTP_CODE})"
    exit 1
  fi
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

# Step 5: check preBuild patch compatibility (optional).
if [[ -n "$PREBUILD_PKG_JSON" ]]; then
  echo ""
  echo "Checking preBuild patch compatibility..."
  BUILD_SCRIPT=$(curl -sL "https://raw.githubusercontent.com/${REPO}/${REF}/${PREBUILD_PKG_JSON}" | grep '"build":')
  echo "New build script: ${BUILD_SCRIPT}"

  CURRENT_OLD=$(grep 'replace-fail' "$NIX_FILE" | head -1 | sed -n 's/.*--replace-fail "\([^"]*\)".*/\1/p')
  if [[ -n "$CURRENT_OLD" && "${BUILD_SCRIPT}" != *"${CURRENT_OLD}"* ]]; then
    echo ""
    echo "⚠️  preBuild patch may need updating:"
    echo "  Old pattern:  ${CURRENT_OLD}"
    echo "  New line:     ${BUILD_SCRIPT}"
  fi
fi

# Summary & apply
echo ""
echo "=== Summary ==="
echo "  version:     ${TARGET_VERSION}"
if [[ "$WRITE_REV" == "true" ]]; then
  echo "  rev:         ${REV}"
fi
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
  # rev is passed only when WRITE_REV is true; the python side substitutes it
  # only when the argument is present.
  REV_ARG=""
  if [[ "$WRITE_REV" == "true" ]]; then
    REV_ARG="$REV"
  fi
  WRITE_REV="$WRITE_REV" python3 -c "
import os, re, sys

nix_file, version, rev, source_hash, npm_deps_hash = sys.argv[1:6]
write_rev = os.environ['WRITE_REV'] == 'true'

with open(nix_file) as f:
    content = f.read()

content = re.sub(r'(^  version = \")([^\"]+)(\")', lambda m: m.group(1) + version + m.group(3), content, count=1, flags=re.MULTILINE)
if write_rev:
    content = re.sub(r'(^    rev = \")([^\"]+)(\")', lambda m: m.group(1) + rev + m.group(3), content, count=1, flags=re.MULTILINE)
content = re.sub(r'(^    hash = \")([^\"]+)(\")', lambda m: m.group(1) + source_hash + m.group(3), content, count=1, flags=re.MULTILINE)
content = re.sub(r'(^  npmDepsHash = \")([^\"]+)(\")', lambda m: m.group(1) + npm_deps_hash + m.group(3), content, count=1, flags=re.MULTILINE)

with open(nix_file, 'w') as f:
    f.write(content)
" "$NIX_FILE" "$TARGET_VERSION" "$REV_ARG" "$SOURCE_HASH" "$NPM_DEPS_HASH"
  echo "Done. Verify, test, and commit."
fi
