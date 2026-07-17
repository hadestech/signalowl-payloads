# Open AP Nmap Scanner

Scans for open (unencrypted) access points, connects to each one in turn, and
runs an Nmap scan of the network behind it, saving the results to the loot
folder. Devices are tracked by BSSID so each AP is only scanned once.

## 1. LED states

| LED | Meaning |
| --- | --- |
| SETUP | Scanning for open access points |
| STAGE1 | Connecting to an open AP |
| STAGE2 | Connected, running the Nmap scan |

## 2. Configuration Variables

Options passed to Nmap. The default `-sP` ping scan is a fast host-discovery
sweep of the address space (see `nmap --help` for more):
```
NMAP_OPTIONS="-sP"
```
Where to write our output (loot):
```
LOOT_DIR=/root/loot/open_ap_nmap_scan
```
Largest network to scan, expressed as a minimum CIDR prefix length. Networks
whose prefix is smaller than this (i.e. larger address spaces) are skipped to
avoid very long scans. With the default, only `/20` and smaller networks are
scanned:
```
MAX_CIDR=20
```
Setting DEBUG to 1 produces verbose output to the console and to
`/tmp/payload.log` (which does not survive a reboot):
```
DEBUG=1
```

## 3. Sample output

Per-AP Nmap results are written to `LOOT_DIR`, one file per access point named
`<ESSID>-<BSSID>.txt`:
```
root@Owl:~/loot/open_ap_nmap_scan# ls -al
-rw-r--r--    1 root     root           412 Aug  7 10:24 CoffeeShop-AA:BB:CC:DD:EE:01.txt
```

## 4. Notes

An external WiFi adapter presented as `wlan0` is required. Because the payload
associates with third-party networks and scans them, only run it where your
rules of engagement permit.
