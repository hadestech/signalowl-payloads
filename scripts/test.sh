#!/usr/bin/env bash
#
# Run the bats test suite. Usage: scripts/test.sh
#
# Requires `bats` on PATH (https://github.com/bats-core/bats-core).

set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v bats >/dev/null 2>&1; then
    echo "bats not found on PATH. Install bats-core to run the suite:" >&2
    echo "  https://github.com/bats-core/bats-core#installation" >&2
    exit 127
fi

exec bats tests/
