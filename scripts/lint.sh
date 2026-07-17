#!/usr/bin/env bash
#
# Lint every payload and extension with shellcheck.
#
# Payloads carry a `.txt` extension but are bash scripts, so we force the
# shell dialect. The gate fails only on `error`-severity findings to keep a
# green baseline; warnings are printed for visibility but don't fail the run.
# Set STRICT=1 to fail on warnings too.

set -uo pipefail

cd "$(dirname "$0")/.."

mapfile -t files < <(find payloads -type f \( -name '*.sh' -o -name 'payload.txt' \) | sort)

if [ "${#files[@]}" -eq 0 ]; then
    echo "No payload scripts found." >&2
    exit 1
fi

gate_severity="error"
[ "${STRICT:-0}" = "1" ] && gate_severity="warning"

echo "== shellcheck report (all severities) =="
for f in "${files[@]}"; do
    shellcheck --shell=bash "$f" || true
done

echo
echo "== gate: failing on severity >= ${gate_severity} =="
rc=0
for f in "${files[@]}"; do
    if shellcheck --shell=bash --severity="$gate_severity" "$f"; then
        echo "OK   $f"
    else
        echo "FAIL $f"
        rc=1
    fi
done

exit "$rc"
