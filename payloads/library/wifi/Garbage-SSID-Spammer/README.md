# Garbage SSID Spammer

Uses `mdk4` to beacon a flood of malformed SSIDs — non-printable names and
names that exceed the 32-byte SSID limit. Useful for testing how nearby
clients and access points cope with non-conforming beacon frames.

## 1. LED states

| LED | Meaning |
| --- | --- |
| SETUP | Bringing up monitor mode on the adapter |
| ATTACK | Beaconing garbage SSIDs with mdk4 |

## 2. How it works

1. `airmon-ng start wlan0` puts the adapter into monitor mode, creating
   `wlan0mon`.
2. `mdk4 wlan0mon b -a -m -s 500` runs the beacon-flood mode:
   - `b` — beacon flooding mode
   - `-a` — advertise fake APs with the WPA/WEP bit set
   - `-m` — use valid, vendor-derived MAC addresses
   - `-s 500` — send at 500 packets per second

## 3. Notes

An external WiFi adapter presented as `wlan0` and capable of monitor mode is
required. Beacon flooding is disruptive to the local RF environment; only run
it where your rules of engagement permit.
