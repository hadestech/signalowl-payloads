# Tests

Automated checks for the Signal Owl payloads. Run in CI on every push to
`master` and every pull request (see `.github/workflows/ci.yml`).

## What runs

- **shellcheck** (`scripts/lint.sh`) — static analysis of every `*.sh` and
  `payload.txt`. The gate fails only on `error`-severity findings so the
  baseline stays green; warnings are printed for visibility. Run
  `STRICT=1 scripts/lint.sh` to fail on warnings too.
- **bats** (`scripts/test.sh` / `bats tests/`) — unit tests for the payload
  logic, run with the hardware commands (`ip`, `iwlist`, `hcitool`, `nmap`,
  `LED`, ...) stubbed out.

## Running locally

```sh
# shellcheck + bats
sudo apt-get install -y shellcheck bats   # or: brew install shellcheck bats-core
./scripts/lint.sh
./scripts/test.sh
```

## How the payload tests work

Payloads are normal bash scripts that define functions and then call `run`
at the top level (an infinite loop on real hardware). `tests/helpers/load.bash`
sources a payload with that top-level `run` invocation stripped and its `run`
function renamed, so the functions can be exercised in isolation. Tests then
override the hardware-facing commands with shell-function stubs and assert on
the parsing/decision logic.

## Coverage today

| Payload | Covered logic |
| --- | --- |
| `wifi/Open-AP-Nmap-Scanner` | subnet/CIDR parsing, open-ESSID extraction, nmap scan-size guard |
| `bluetooth/Bluetooth-Scanner` | new-vs-seen MAC de-duplication |
| `general/arming-mode` | firmware-version gate |
| all payloads | shebang + Title/Author/Version metadata |

Good next additions: README-per-payload enforcement, coverage for the
`Delayed-AP-Attack` capture-move path, and fixing the warning-level
shellcheck findings (then flipping the gate to `STRICT`).
