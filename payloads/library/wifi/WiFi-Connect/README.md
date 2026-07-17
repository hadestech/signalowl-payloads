# Simple WiFi Connection Example

A minimal example showing how to bring the Signal Owl online as a WiFi client.
It sets the target network's credentials and hands off to the `WIFI_CONNECT`
helper, then (optionally) starts an SSH server so you can reach the device over
the network.

## 1. LED states

| LED | Meaning |
| --- | --- |
| SETUP | Associating with the configured network |
| ATTACK | Connected |

## 2. Configuration Variables

The SSID and passphrase of the network to join. They are exported so the
`WIFI_CONNECT` extension function can read them from the environment:
```
export WIFI_SSID="network-name"
export WIFI_PASS="passphrase"
```

## 3. Dependencies

Relies on the `WIFI_CONNECT` extension (`payloads/extensions/wifi_connect.sh`),
which builds a `wpa_supplicant` config from `$WIFI_SSID` / `$WIFI_PASS`,
associates `wlan0`, and requests a DHCP lease.

## 4. Notes

Uncomment the `/etc/init.d/sshd start` line to start the SSH server once
connected.
