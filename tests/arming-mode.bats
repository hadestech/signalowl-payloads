#!/usr/bin/env bats
#
# Unit tests for payloads/library/general/arming-mode/payload.txt
#
# check_version reads /etc/owl/VERSION via `cat`; we override `cat` to feed
# it controlled input and assert the firmware-version gate.

load helpers/load

PAYLOAD="payloads/library/general/arming-mode/payload.txt"

setup() {
    load_payload "$REPO_ROOT/$PAYLOAD"
}

@test "check_version succeeds on the supported firmware version" {
    cat() { echo "1.0.0"; }

    run check_version
    [ "$status" -eq 0 ]
}

@test "check_version fails on an unsupported firmware version" {
    cat() { echo "2.0.0"; }

    # The error message is written to /dev/console (not stdout), so we assert
    # on the exit status, which is the gate `run` actually keys off of.
    run check_version
    [ "$status" -eq 1 ]
}
