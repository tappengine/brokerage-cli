# bm — Buildmarkets CLI

The official command-line interface for the Buildmarkets brokerage API. A single
static binary for macOS, Linux, and Windows.

> This repository hosts the **published binaries** (see
> [Releases](https://github.com/tappengine/brokerage-cli/releases)) and install
> tooling. The source is maintained privately.

## Install

| Platform | Command |
|---|---|
| macOS / Linux (curl) | `curl -fsSL https://raw.githubusercontent.com/tappengine/brokerage-cli/main/install.sh \| sh` |
| macOS (Homebrew) | `brew install tappengine/tap/bm` |
| Any | Download the binary for your OS/arch from [Releases](https://github.com/tappengine/brokerage-cli/releases/latest) |

After installing, verify:

```bash
bm --version
```

## Quick start

```bash
# Partner / API key
bm config set environment qa            # sandbox | qa | live
bm config set api-key    <key>
bm config set api-secret <secret>
bm whoami
bm marketdata quote AAPL

# Trader / OAuth
bm login
```

## Authentication

Two modes (resolved in order, first match wins):

1. `--api-key` / `--api-secret` flags
2. `BUILDMARKETS_API_KEY` / `BUILDMARKETS_API_SECRET` env vars
3. Keycloak token from `bm login` (OAuth device flow)
4. API key + secret from `bm config`

Credentials are stored in the OS keychain (or `~/.buildmarkets/config.yaml` at
`0600` if no keychain is available).

## Output & exit codes

- Table on a TTY, JSON when piped. `--json` / `--table` force the format.
- Data → stdout, diagnostics → stderr.
- Exit codes: `0` ok, `1` generic, `2` validation, `3` auth, `4` not found,
  `5` rate limited, `6` upstream unavailable.

## Commands

```
bm accounts | orders | positions | funding | marketdata | webhooks | documents | keys | system
bm webhooks tail        # stream/forward webhook events locally
bm logs tail            # stream API request logs
bm dev sandbox reset    # reseed a sandbox tenant
bm migrate from-alpaca  # migrate from the Alpaca Broker API
```

Run `bm <command> --help` for details.

## Documentation

- **[Developer Guide](docs/DEVELOPER_GUIDE.md)** — install, auth, configuration,
  every command with required parameters and examples, and scripting recipes.
- **[Command Reference](docs/COMMAND_REFERENCE.md)** — the full flag-level
  reference for all commands.

## Support

Issues and questions: contact the Buildmarkets team.
