#!/usr/bin/env bats
#
# Unit tests for payloads/library/bluetooth/Bluetooth-Scanner/payload.txt
#
# Focuses on the "already seen this MAC" de-duplication logic in
# scan_bluetooth, with hcitool and LED stubbed.

load helpers/load

PAYLOAD="payloads/library/bluetooth/Bluetooth-Scanner/payload.txt"

setup() {
    load_payload "$REPO_ROOT/$PAYLOAD"
    DEBUG=0
    LOOT_DIR="$BATS_TEST_TMPDIR/loot"
    mkdir -p "$LOOT_DIR"
    # scan_bluetooth greps this file to decide what is new; create it.
    : > "$LOOT_DIR/$BT_OUTFILE"
}

@test "scan_bluetooth logs a newly observed device" {
    hcitool() { printf 'Scanning ...\n\tAA:BB:CC:DD:EE:01\tPhone\n'; }

    scan_bluetooth || true

    [ "$total_bts" -eq 1 ]
    run grep -c "AA:BB:CC:DD:EE:01" "$LOOT_DIR/$BT_OUTFILE"
    [ "$output" -eq 1 ]
}

@test "scan_bluetooth does not re-log an already seen device" {
    printf 'seed line AA:BB:CC:DD:EE:01\n' > "$LOOT_DIR/$BT_OUTFILE"
    hcitool() { printf 'Scanning ...\n\tAA:BB:CC:DD:EE:01\tPhone\n'; }

    scan_bluetooth || true

    # Still exactly one occurrence: the seed line, no duplicate appended.
    run grep -c "AA:BB:CC:DD:EE:01" "$LOOT_DIR/$BT_OUTFILE"
    [ "$output" -eq 1 ]
}

@test "scan_bluetooth logs only the new device out of a mixed batch" {
    printf 'seed line AA:BB:CC:DD:EE:01\n' > "$LOOT_DIR/$BT_OUTFILE"
    hcitool() {
        printf 'Scanning ...\n\tAA:BB:CC:DD:EE:01\tKnown\n\tAA:BB:CC:DD:EE:02\tNew\n'
    }

    scan_bluetooth || true

    [ "$total_bts" -eq 2 ]
    run grep -c "AA:BB:CC:DD:EE:02" "$LOOT_DIR/$BT_OUTFILE"
    [ "$output" -eq 1 ]
}
