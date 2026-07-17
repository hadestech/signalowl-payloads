#!/usr/bin/env bats
#
# Unit tests for payloads/library/wifi/Open-AP-Nmap-Scanner/payload.txt
#
# These exercise the parsing/decision logic in isolation by stubbing the
# hardware commands (ip, iwlist, nmap, LED). DEBUG is forced off so the
# tee-to-log lines stay quiet.

load helpers/load

PAYLOAD="payloads/library/wifi/Open-AP-Nmap-Scanner/payload.txt"

setup() {
    load_payload "$REPO_ROOT/$PAYLOAD"
    DEBUG=0
    TESTTMP="$BATS_TEST_TMPDIR"
}

@test "find_subnet derives the .0 network from an ip addr line" {
    # `ip addr` inet lines end with the interface label, which is how the
    # payload's `grep wlan0 | grep inet` pipeline selects the right line.
    ip() {
        cat <<'EOF'
2: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 state UP
    inet 192.168.1.55/24 brd 192.168.1.255 scope global wlan0
EOF
    }

    # `|| true`: the function's last statement is a DEBUG-guarded log line
    # that returns non-zero when DEBUG=0; we care about the SUBNET side effect.
    find_subnet || true

    [ "$SUBNET" = "192.168.1.0/24" ]
}

@test "find_subnet yields empty when wlan0 has no address" {
    ip() {
        cat <<'EOF'
2: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 state DOWN
EOF
    }

    find_subnet || true

    [ -z "$SUBNET" ]
}

@test "scan_wifi extracts open ESSIDs at the expected column offset" {
    # iwlist output uses fixed indentation; the payload relies on `cut -c 28-`
    # landing exactly on the ESSID value. This fixture matches real spacing:
    # 20 leading spaces + `ESSID:"` = 27 chars, so the name starts at col 28.
    iwlist() {
        cat <<'EOF'
          Cell 01 - Address: AA:BB:CC:DD:EE:01
                    Encryption key:off
                    ESSID:"OpenCafe"
          Cell 02 - Address: AA:BB:CC:DD:EE:02
                    Encryption key:on
                    ESSID:"SecureNet"
EOF
    }

    scan_wifi || true

    [ "$total_aps" -eq 1 ]
    run cat /tmp/open
    [ "$output" = "OpenCafe" ]
}

@test "scan_network runs nmap when the subnet is small enough" {
    MAX_CIDR=20
    LOOT_DIR="$TESTTMP/loot"
    mkdir -p "$LOOT_DIR"
    current_ap="OpenCafe"
    APMAC="AA:BB:CC:DD:EE:01"
    NMAP_OPTIONS="-sP"

    # /24 is >= /20, so a scan should fire.
    find_subnet() { SUBNET="192.168.1.0/24"; }
    nmap() { echo "nmap $*" > "$TESTTMP/nmap.called"; }

    scan_network

    [ -f "$TESTTMP/nmap.called" ]
}

@test "scan_network skips nmap when the subnet is too large" {
    MAX_CIDR=20
    LOOT_DIR="$TESTTMP/loot"
    mkdir -p "$LOOT_DIR"
    current_ap="OpenCafe"
    APMAC="AA:BB:CC:DD:EE:01"
    NMAP_OPTIONS="-sP"

    # /16 is < /20 (larger network), so the scan should be skipped.
    find_subnet() { SUBNET="10.0.0.0/16"; }
    nmap() { echo "nmap $*" > "$TESTTMP/nmap.called"; }

    scan_network

    [ ! -f "$TESTTMP/nmap.called" ]
}
