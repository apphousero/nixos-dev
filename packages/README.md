# Packages

Custom Nix packages for `nixos-dev`.

## pi

[pi](https://github.com/badlogic/pi-mono) - an AI coding agent that can read/write files, execute commands, and edit code.

- npm: [@mariozechner/pi-coding-agent](https://www.npmjs.com/package/@mariozechner/pi-coding-agent)
- Binary: `pi`

### Updating pi

**Automated** (recommended):

```sh
# Auto-pick latest version
./packages/update-aph-pi.sh

# Update to a specific version
./packages/update-aph-pi.sh 0.71.0

# Preview changes without writing
./packages/update-aph-pi.sh --dry-run 0.71.0
```

This script handles all 6 steps below automatically.

**Manual steps:**

1. Get the latest version:

   ```sh
   curl -s 'https://registry.npmjs.org/@mariozechner/pi-coding-agent/latest' | jq -r '.version'
   ```

2. Get the git commit for that version:

   ```sh
   curl -s 'https://registry.npmjs.org/@mariozechner/pi-coding-agent/<VERSION>' | jq -r '.gitHead'
   ```

3. Get the source hash:

   ```sh
   nix hash to-sri --type sha256 $(nix-prefetch-url --unpack "https://github.com/badlogic/pi-mono/archive/<COMMIT>.tar.gz" 2>&1 | tail -1)
   ```

4. Get the npm deps hash — build with the new source, then hash the resulting `npmDeps`:

   ```sh
   nix-build -E 'let pkgs = import <nixpkgs> {}; in (pkgs.callPackage ./packages/aph-pi.nix {}).overrideAttrs (old: { version = "<VERSION>"; })'
   # Find the npm-deps store path in output and hash it:
   nix hash path /nix/store/...-npm-deps
   ```

5. Update `pi.nix` with the new `version`, `rev`, `hash`, and `npmDepsHash`.

6. Verify the `preBuild` patch still applies:

   ```sh
   curl -sL "https://raw.githubusercontent.com/badlogic/pi-mono/<COMMIT>/packages/ai/package.json" | grep '"build":'
   ```

   If the build script changed, update the `--replace-fail` strings in `preBuild`.
