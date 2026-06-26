# bm — Buildmarkets CLI

A thin, scriptable command-line front end to the Buildmarkets brokerage API for
humans at terminals, CI/CD pipelines, and focused-action agents. Single static
Go binary, no runtime dependencies. The CLI talks to the API gateway **directly**
— never through the MCP.

```
bm login                                   # trader (OAuth device flow)
bm config set environment sandbox
bm orders place --account <id> --symbol AAPL --side buy --qty 10 --type market
```

## Install

| Platform | Command |
|---|---|
| macOS (Homebrew) | `brew install buildmarkets/tap/bm` |
| Linux/macOS (curl) | `curl -fsSL https://cli.buildmarkets.com/install.sh \| sh` |
| Windows (Scoop) | `scoop install bm` |
| Any (Go) | `go install github.com/tappengine/brokerage-cli@latest` |
| Any | Download from [GitHub Releases](https://github.com/tappengine/brokerage-cli/releases) |

The binary installs as `bm` with a `buildmarkets` long-form alias.

## Authentication

Two modes only (resolved in this order; the first match wins):

1. `--api-key` / `--api-secret` flags
2. `BUILDMARKETS_API_KEY` / `BUILDMARKETS_API_SECRET` env vars
3. Keycloak access token from `bm login` (OAuth device flow, trader)
4. API key + secret from `bm config` (partner / M2M)

Credentials are stored in the OS keychain (macOS Keychain, Windows Credential
Manager, libsecret on Linux), falling back to `~/.buildmarkets/config.yaml`
(0600) only when no keychain is available.

```
bm login                       # trader
bm config set api-key  <key>   # partner
bm config set api-secret <secret>
bm whoami
bm logout
```

## Output

- **TTY** → table by default. **Non-TTY** → JSON by default (auto-detected).
- `--json` / `--table` force the format.
- Data goes to **stdout**, all diagnostics and errors to **stderr** — always.

## Interaction modes

- Interactive (default): confirms before the three bulk-destructive commands
  (`orders cancel-all`, `positions close-all`, `accounts close`).
- `--non-interactive` or `BUILDMARKETS_NON_INTERACTIVE=1`: zero prompts, zero
  color, zero animation — for agents and CI. `--yes` skips a single prompt.

## Exit codes

| Code | Meaning |
|---|---|
| 0 | success |
| 1 | generic error |
| 2 | validation error |
| 3 | auth error |
| 4 | not found |
| 5 | rate limited |
| 6 | upstream unavailable |

## Command surface

The bulk of the surface is **generated from the OpenAPI spec** (`generated/`,
never hand-edited) and grouped by resource:

```
bm accounts   list | get <id> | open | update <id> | close <id> | balances <id>
bm orders     place | list | get | modify | cancel | executions | cancel-all
bm positions  list | get | close-all
bm funding    deposit | withdraw | activity | ach (link|list|remove)
bm marketdata quote | historical | profile | dividends | news | options ...
bm webhooks   create | list | get | update | delete | test | deliveries | tail
bm documents  list | types | upload | email | w9
bm keys       create | list | revoke
bm system     health | ready | live | metrics
```

Hand-written **wedge commands** layer on top:

- `bm webhooks tail` — stream/forward webhook events locally (no tunnel needed)
- `bm logs tail` — stream API request logs for your tenant
- `bm dev sandbox reset` — wipe and reseed a sandbox tenant
- `bm migrate from-alpaca plan|apply|status` — Alpaca Broker API migration

### `--watch`

Read commands accept `--watch` (poll every 2s, `--watch-interval <s>` to
override). On a TTY it re-renders the table; off a TTY it emits newline-delimited
JSON (NDJSON). `tail` commands stream natively and ignore `--watch`.

## Environment variables

| Variable | Effect |
|---|---|
| `BUILDMARKETS_ENV` | `sandbox` / `live` |
| `BUILDMARKETS_API_KEY` / `BUILDMARKETS_API_SECRET` | partner auth |
| `BUILDMARKETS_NON_INTERACTIVE` | disable prompts/color |
| `BUILDMARKETS_NO_UPDATE_CHECK` | skip the auto-update check |
| `BUILDMARKETS_DEBUG` | verbose logging to stderr |
| `BUILDMARKETS_API_BASE_URL` / `BUILDMARKETS_AUTH_*` | endpoint overrides |

## Development

```
make build       # build ./bm for the current platform
make generate    # regenerate generated/ from the OpenAPI spec
make cross       # cross-compile all 5 release targets into dist/
make test vet    # tests and static analysis
```

The `generated/` package is checked in but produced entirely by
`go run ./generator`. Any change to the API surface flows through
OpenAPI → `make generate` → CI → release. The release workflow fails if
`generated/` is stale.

### `[VERIFY-BACKEND]` endpoints

The streaming wedges depend on endpoints not yet in the OpenAPI spec
(`GET /v1/webhooks/stream`, `GET /v1/logs/stream`, `POST /v1/dev/sandbox/reset`,
`GET /v1/dev/sandbox/test-paths`). They are built to the documented contracts
with graceful fallback; confirm the SSE event shapes and forwarded webhook
signature header names with the backend team before relying on them (spec §10).
