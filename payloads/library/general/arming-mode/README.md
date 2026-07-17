# Arming Mode

Reference implementation of the Signal Owl's ARMING mode. It verifies the
firmware version, brings up the wireless radio, starts the SSH server, and
signals readiness on the LED — giving you a management network to configure the
device before deploying a payload.

## 1. LED states

| LED | Meaning |
| --- | --- |
| R DOUBLE | Armed and ready (radio up, SSH running) |

## 2. What it does

1. `check_version` reads `/etc/owl/VERSION` and requires firmware `1.0.0`. If
   it does not match, an error is written to the console and the payload stops.
2. `configure_network` enables `wireless.radio0` via UCI, commits the change,
   and restarts networking.
3. `start_ssh` starts the SSH daemon.
4. `ARMING` is written to `/tmp/MODE` and the LED is set to the double-red
   arming pattern.

## 3. Notes

Requires firmware version `1.0.0`; update the version check in the payload if
you are running a newer firmware.
