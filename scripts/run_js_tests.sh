#!/usr/bin/env bash
# Run the JS unit suite (tests/js/) under the runtime pinned in
# package.json.
#
# The suite runs under the node binary installed by the bootstrap - the
# `node` devDependency - so every machine runs the same runtime the
# lockfile pins, independent of what node the machine itself has. The
# script is called from the pre-commit hook and from the pytest wrapper
# (tests/unit/test_js_unit.py); it is also the direct way to run the JS
# suite without the Python wrapper.
set -euo pipefail
cd "$(dirname "$0")/.."

NODE_BIN="node_modules/.bin/node"

if [ ! -x "$NODE_BIN" ]; then
    if ! command -v npm >/dev/null 2>&1; then
        echo "js-tests: node and npm are required to bootstrap the pinned node runtime (node_modules/.bin/node); install node and npm, or run 'npm ci' first" >&2
        exit 1
    fi
    # Phase 1: install the locked tree with the machine's npm; this
    # extracts the pinned node runtime.
    npm ci --no-audit --no-fund
    # Phase 2: npm skips the platform optionalDependencies of the
    # transitive native bindings when the running node is below their
    # engine floor (Debian 12 ships node 18; the bindings need node >= 20).
    # Redo the install under the pinned runtime so the bindings for this
    # machine land. No-op when the machine's node is new enough.
    if ! node -e "process.exit(parseInt(process.versions.node) >= 22 ? 0 : 1)" 2>/dev/null; then
        "$NODE_BIN" "$(command -v npx)" -y npm@10 ci --no-audit --no-fund
    fi
fi

exec "$NODE_BIN" node_modules/vitest/vitest.mjs run --coverage
