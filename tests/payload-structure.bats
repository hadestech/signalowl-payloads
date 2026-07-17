#!/usr/bin/env bats
#
# Convention checks for every payload in the library. Keeps new payloads
# consistent: each must be a bash script and carry Title/Author/Version
# metadata in its header comment.

load helpers/load

# Collect all payload.txt files under the library.
payloads() {
    find "$REPO_ROOT/payloads/library" -name 'payload.txt'
}

@test "at least one payload exists" {
    run bash -c "find '$REPO_ROOT/payloads/library' -name 'payload.txt' | wc -l"
    [ "$output" -ge 1 ]
}

@test "every payload starts with a bash shebang" {
    local failures=""
    while IFS= read -r p; do
        head -n1 "$p" | grep -q '^#!/bin/bash' || failures+=$'\n'"$p"
    done < <(payloads)
    [ -z "$failures" ] || { echo "Missing bash shebang:$failures"; false; }
}

@test "every payload declares Title, Author and Version" {
    local failures=""
    while IFS= read -r p; do
        for field in Title Author Version; do
            grep -qiE "^#[[:space:]]*${field}:" "$p" \
                || failures+=$'\n'"$p (missing $field)"
        done
    done < <(payloads)
    [ -z "$failures" ] || { echo "Missing metadata:$failures"; false; }
}
