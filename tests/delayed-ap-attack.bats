#!/usr/bin/env bats
#
# Unit tests for payloads/library/wifi/Delayed-AP-Attack-Mine/payload.txt
#
# Exercises collect_loot, the step that moves besside-ng's output into the
# loot directory. CAP_SRC points the source at a temp dir so the test never
# touches the real filesystem root.

load helpers/load

PAYLOAD="payloads/library/wifi/Delayed-AP-Attack-Mine/payload.txt"

setup() {
    load_payload "$REPO_ROOT/$PAYLOAD"
    CAP_SRC="$BATS_TEST_TMPDIR/src"
    LOOT_DIR="$BATS_TEST_TMPDIR/loot"
    mkdir -p "$CAP_SRC"
}

@test "collect_loot moves capture files into the loot dir" {
    touch "$CAP_SRC/wpa-01.cap" "$CAP_SRC/wpa-02.cap"

    collect_loot

    [ -f "$LOOT_DIR/wpa-01.cap" ]
    [ -f "$LOOT_DIR/wpa-02.cap" ]
    # moved, not copied
    [ ! -e "$CAP_SRC/wpa-01.cap" ]
    [ ! -e "$CAP_SRC/wpa-02.cap" ]
}

@test "collect_loot moves besside.log into the loot dir" {
    echo "log data" > "$CAP_SRC/besside.log"

    collect_loot

    [ -f "$LOOT_DIR/besside.log" ]
    [ ! -e "$CAP_SRC/besside.log" ]
}

@test "collect_loot succeeds with no captures and no log (empty run)" {
    # Regression: the old `mv /*.cap /root/loot` errored when the glob matched
    # nothing, right before poweroff. An empty run must now exit cleanly.
    run collect_loot
    [ "$status" -eq 0 ]

    # Nothing should have been moved into the loot dir.
    run ls -A "$LOOT_DIR"
    [ -z "$output" ]
}

@test "collect_loot handles a mixed batch (log + captures)" {
    echo "log data" > "$CAP_SRC/besside.log"
    touch "$CAP_SRC/wpa-01.cap"

    collect_loot

    [ -f "$LOOT_DIR/besside.log" ]
    [ -f "$LOOT_DIR/wpa-01.cap" ]
}
