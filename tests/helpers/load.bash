# Test helpers for sourcing Signal Owl payloads and stubbing the
# hardware-facing commands they call (LED, iwlist, hcitool, nmap, ...).
#
# Payloads are normal scripts that define functions and then call `run`
# at the top level (which loops forever on real hardware). load_payload
# strips that final top-level `run` invocation so the file can be sourced
# to get at its functions without executing the payload.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Source a payload's function/variable definitions without running it.
#  - drops the top-level `run` invocation (e.g. `run`, `run &> /dev/null`)
#    so the payload loop doesn't execute on source, and
#  - renames the payload's `run` function to `payload_run` so it doesn't
#    shadow bats's own `run` test helper.
load_payload() {
    local file="$1"
    source <(sed -E \
        -e '/^[[:space:]]*run([[:space:]]|&|$)/d' \
        -e 's/^function run\(\)/function payload_run()/' \
        "$file")
}

# Default no-op stubs for commands the Signal Owl firmware provides but
# that don't exist in CI. Individual tests override these as needed.
LED() { :; }
