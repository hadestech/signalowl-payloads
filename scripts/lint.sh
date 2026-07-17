#!/usr/bin/env bash
#
# Lint every payload and extension with shellcheck.
#
# Payloads carry a `.txt` extension but are bash scripts, so we force the
# shell dialect. The gate fails on `warning`-severity findings and above.
# Override with SHELLCHECK_SEVERITY (error|warning|info|style) to relax or
# tighten it, e.g. SHELLCHECK_SEVERITY=error scripts/lint.sh.

set -uo pipefail

cd "$(dirname "$0")/.."

mapfile -t files < <(find payloads -type f \( -name '*.sh' -o -name 'payload.txt' \) | sort)

if [ "${#files[@]}" -eq 0 ]; then
    echo "No payload scripts found." >&2
    exit 1
fi

gate_severity="${SHELLCHECK_SEVERITY:-warning}"

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
