# bm — Developer Guide

Complete usage guide for the Buildmarkets CLI. For the exhaustive per-command
reference (every flag, auto-generated from the binary), see
[`docs/COMMAND_REFERENCE.md`](./COMMAND_REFERENCE.md). Any command also self-documents:

```bash
bm <command> --help
bm orders place --help
```

---

## Contents

- [Install](#install)
- [Authentication](#authentication)
- [Configuration & environments](#configuration--environments)
- [Global flags & conventions](#global-flags--conventions)
- [Output formats](#output-formats)
- [Exit codes](#exit-codes)
- [Commands by resource](#commands-by-resource)
  - [system](#system) · [accounts](#accounts) · [orders](#orders) ·
    [positions](#positions) · [funding](#funding) · [marketdata](#marketdata) ·
    [documents](#documents) · [keys](#keys) · [webhooks](#webhooks)
- [Developer wedge commands](#developer-wedge-commands)
  - [webhooks tail](#bm-webhooks-tail) · [logs tail](#bm-logs-tail) ·
    [dev sandbox reset](#bm-dev-sandbox-reset) · [migrate from-alpaca](#bm-migrate-from-alpaca)
- [Scripting recipes](#scripting-recipes)

---

## Install

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/tappengine/brokerage-cli/main/install.sh | sh
# Homebrew
brew install tappengine/tap/bm
# verify
bm --version
```

---

## Authentication

Two modes. Credentials resolve in this order — **first match wins**:

| Priority | Source |
|---|---|
| 1 | `--api-key` / `--api-secret` flags |
| 2 | `BUILDMARKETS_API_KEY` / `BUILDMARKETS_API_SECRET` env vars |
| 3 | Keycloak token from `bm login` (trader) |
| 4 | API key + secret from `bm config` (partner) |

### Partner / M2M (API key)
```bash
bm config set api-key    tapp_sandbox_xxx     # stored in OS keychain
bm config set api-secret sk_xxx
```
Sent as `X-API-Key` + `X-API-Secret` headers.

### Trader (OAuth device flow)
```bash
bm login        # prints a code + URL; approve in the browser
bm whoami
bm logout
```
Sent as `Authorization: Bearer <jwt>`. Token auto-refreshes; stored in the keychain.

> Credentials live in the OS keychain (macOS Keychain / Windows Credential Manager
> / libsecret). Only if no keychain exists do they fall back to
> `~/.buildmarkets/config.yaml` at `0600`.

---

## Configuration & environments

```bash
bm config set environment qa     # sandbox | qa | live
bm config get  api-base-url       # effective value (after env overrides)
bm config list                    # everything (secrets masked)
```

| environment | API base URL |
|---|---|
| `sandbox` | `https://dev-tapp-api.tappengine.com` |
| `qa` | `https://qa-tapp-api.tappengine.com` |
| `live` | `https://tapp-api.tappengine.com` |

Override any value via env var (env always wins — ideal for CI):

| Env var | Effect |
|---|---|
| `BUILDMARKETS_ENV` | environment |
| `BUILDMARKETS_API_KEY` / `_API_SECRET` | partner auth |
| `BUILDMARKETS_API_BASE_URL` | force a specific gateway URL |
| `BUILDMARKETS_AUTH_BASE_URL` / `_AUTH_REALM` / `_AUTH_CLIENT_ID` | Keycloak coordinates |
| `BUILDMARKETS_NON_INTERACTIVE` | disable prompts/color |
| `BUILDMARKETS_NO_UPDATE_CHECK` | skip the update check |
| `BUILDMARKETS_DEBUG` | verbose request logging to stderr |

---

## Global flags & conventions

Available on every command:

| Flag | Purpose |
|---|---|
| `--json` / `--table` | force output format (else auto-detect) |
| `--non-interactive` | no prompts, color, or animation (CI/agents) |
| `--yes` | skip a confirmation prompt |
| `--api-key` / `--api-secret` | per-invocation partner auth |
| `--debug` | verbose logging to stderr |
| `--watch` / `--watch-interval <s>` | poll a read command (default 2s) |
| `--no-update-check` | skip the update check |

**Argument conventions** (consistent everywhere):

| Pattern | Rule | Example |
|---|---|---|
| Target resource id | positional | `bm accounts get <id>` |
| Parent scope | `--account` flag | `bm orders list --account <id>` |
| Creation data | flags | `bm orders place --symbol AAPL …` |
| Boolean | `--flag` / `--no-flag` | `--watch` / `--no-watch` |

---

## Output formats

- **TTY → table**, **piped → JSON** (auto-detected). Force with `--json`/`--table`.
- Data → **stdout**; errors, prompts, notices → **stderr**.
- `--watch` off a TTY emits **NDJSON** (one JSON object per poll) for stream-parsing.

```bash
bm marketdata quote AAPL                 # table
bm marketdata quote AAPL --json | jq .data.lastPrice
bm accounts list --watch --watch-interval 5
```

---

## Exit codes

Stable across releases — script against them:

| Code | Meaning |
|---|---|
| 0 | success |
| 1 | generic error |
| 2 | validation error (bad input) |
| 3 | auth error |
| 4 | not found |
| 5 | rate limited |
| 6 | upstream unavailable |

```bash
bm accounts get bad-id; echo $?     # -> 4
```

---

## Commands by resource

> Legend: **R** = required. Positional `<args>` are required by position.

### system
Unauthenticated health/metrics.
```bash
bm system health        # {"status":"ok",...}
bm system ready
bm system live
bm system metrics
```

### accounts

| Command | Required | Notes |
|---|---|---|
| `bm accounts list` | — | filters: `--status`, `--query`, `--created-after/-before`, `--sort`, `--limit`, `--cursor` |
| `bm accounts get <id>` | `<id>` | UUID or account number (e.g. `TAPP-AFP-1257090`) |
| `bm accounts balances <id>` | `<id>` | cash, buying power, equity, margin |
| `bm accounts open` | `--data` **or** `--interactive` | opens an account with inline KYC |
| `bm accounts update <id>` | `<id>`, `--data` | identity fields editable only while pending |
| `bm accounts close <id>` | `<id>` | **confirms** (bulk-destructive) |

```bash
bm accounts list --status ACTIVE --limit 25
bm accounts get TAPP-AFP-1257090
bm accounts balances 550e8400-e29b-41d4-a716-446655440000

# Open an account — interactive (walks you through KYC):
bm accounts open --interactive
# …or scripted with a full body:
bm accounts open --data @account.json
```
> **Sandbox KYC test paths:** `tax_id` ending `0001`=approved, `0002`=rejected,
> `0003`=manual_review.  `bm sandbox test-paths` lists them.

### orders

| Command | Required | Notes |
|---|---|---|
| `bm orders place` | `--account`, `--symbol`, `--side` | see below |
| `bm orders list` | `--account` | |
| `bm orders get <order-id>` | `--account`, `<order-id>` | |
| `bm orders modify <order-id>` | `--account`, `<order-id>` | `--limit-price`, `--qty` |
| `bm orders cancel <order-id>` | `--account`, `<order-id>` | |
| `bm orders executions <order-id>` | `--account`, `<order-id>` | fills |
| `bm orders cancel-all` | `--account` | **confirms** (bulk-destructive) |

**`orders place` flags:**

| Flag | Required | Default | Values |
|---|---|---|---|
| `--account` | **R** | — | account UUID |
| `--symbol` | **R** | — | e.g. `AAPL` |
| `--side` | **R** | — | `buy` \| `sell` |
| `--qty` (`--quantity`) | one of qty/notional | — | share count |
| `--notional` | one of qty/notional | — | dollar amount |
| `--order-type` (`--type`) | | `market` | `market` \| `limit` |
| `--time-in-force` | | `day` | `day` `gtc` `opg` `cls` `ioc` `fok` |
| `--asset-class` | | `equity` | `equity` \| `etf` |
| `--limit-price` | for limit orders | — | |
| `--client-order-id` | | auto-generated | idempotency key |
| `--extended-hours` | | false | |

```bash
# Market buy (defaults: equity, market, day):
bm orders place --account <id> --symbol AAPL --side buy --qty 10 --type market

# Limit order:
bm orders place --account <id> --symbol MSFT --side buy --qty 5 \
  --type limit --limit-price 410.00 --time-in-force gtc

# Notional (dollar-based):
bm orders place --account <id> --symbol AAPL --side buy --notional 1000.00
```

### positions

| Command | Required | Notes |
|---|---|---|
| `bm positions list` | `--account` | real-time P&L |
| `bm positions get <symbol>` | `--account`, `<symbol>` | single position |
| `bm positions close-all` | `--account` | **confirms** — liquidates all at market |

```bash
bm positions list --account <id>
bm positions get AAPL --account <id>
```

### funding

| Command | Required | Notes |
|---|---|---|
| `bm funding deposit` | `--account`, `--ach`, `--amount` | ACH credit |
| `bm funding withdraw` | `--account`, `--ach` | `--amount` or `--withdraw-full-balance` |
| `bm funding ach link` | `--account` + bank fields | links a bank account |
| `bm funding ach list` | `--account` | |
| `bm funding ach remove <ach-id>` | `--account`, `<ach-id>` | |
| `bm funding activity` | `--account` | deposits + withdrawals |
| `bm funding activity-detail <activity-id>` | `--account`, `<activity-id>` | |

```bash
bm funding deposit  --account <id> --ach <ach-id> --amount 1000.00 --description "Initial"
bm funding withdraw --account <id> --ach <ach-id> --amount 500.00
bm funding withdraw --account <id> --ach <ach-id> --withdraw-full-balance

# Link a bank (ACH):
bm funding ach link --account <id> \
  --bank-account-owner-name "Sarah Martinez" \
  --bank-account-type CHECKING \
  --bank-routing-number 021000021 \
  --bank-account-number 1234567890
```
> Amounts are strings with 2 decimals (`"1000.00"`) to preserve precision.

### marketdata

| Command | Required | Notes |
|---|---|---|
| `bm marketdata quote <symbol>` | `<symbol>` | real-time bid/ask/last |
| `bm marketdata profile <symbol>` | `<symbol>` | company profile |
| `bm marketdata historical <symbol>` | `<symbol>` | `--from` / `--to` (YYYY-MM-DD) |
| `bm marketdata dividends <symbol>` | `<symbol>` | `--excluding-from/-to` |
| `bm marketdata news <symbol>` | `<symbol>` | `--limit` |
| `bm marketdata balance-sheet <symbol>` | `<symbol>` | `--statement-type`, `--number-of-reports` |
| `bm marketdata logo <symbol>` | `<symbol>` | |
| `bm marketdata industries` / `sectors` | — | reference lists |
| `bm marketdata securities` | — | `--symbol`, `--limit`, `--offset` |
| `bm marketdata symbol-details` | `--symbols` | comma-separated |
| `bm marketdata options chain` | `--symbol`, `--expiration` | |
| `bm marketdata options strikes` | `--symbol`, `--expiration` | |
| `bm marketdata options expirations` | `--symbol` | `--strikes` for counts |
| `bm marketdata options lookup` | `--underlying` | up to 30, comma-separated |

```bash
bm marketdata quote AAPL
bm marketdata historical AAPL --from 2026-01-01 --to 2026-05-01
bm marketdata options chain --symbol AAPL --expiration 2026-07-17
bm marketdata symbol-details --symbols AAPL,MSFT,GOOGL
```

### documents

| Command | Required | Notes |
|---|---|---|
| `bm documents types` | — | supported document types |
| `bm documents list` | — | `--limit`, `--offset`, `--document-type-id`, `--account-number`, `--month/--year/--date` |
| `bm documents upload` | `--account`, `--type`, `--file` | base64-encoded; mime inferred |
| `bm documents email` | `--document-url` | `--email` |
| `bm documents w9` | `--user-id` | |

```bash
bm documents upload --account <id> --type w8ben --file ./form.pdf
bm documents list --account-number TAPP-AFP-1257090 --limit 5
```

### keys

| Command | Required | Notes |
|---|---|---|
| `bm keys create` | `--label`, `--scopes` | secret returned once |
| `bm keys list` | — | `--limit`, `--offset` |
| `bm keys revoke <keyId>` | `<keyId>` | |

```bash
bm keys create --label "ci-pipeline" --scopes read,trade
```

### webhooks

| Command | Required | Notes |
|---|---|---|
| `bm webhooks create` | `--url`, `--events` | empty `--events` = all |
| `bm webhooks list` | — | |
| `bm webhooks get <id>` | `<id>` | |
| `bm webhooks update <id>` | `<id>` | `--url`, `--events`, `--status` |
| `bm webhooks delete <id>` | `<id>` | |
| `bm webhooks test <id>` | `<id>` | send a test event |
| `bm webhooks deliveries <id>` | `<id>` | delivery attempts |
| `bm webhooks tail` | — | live stream (see below) |

```bash
bm webhooks create --url https://partner.com/webhooks \
  --events account.kyc_approved,order.filled,funding.deposit_completed
```

---

## Developer wedge commands

### `bm webhooks tail`
Stream webhook events to your terminal or forward them to a local URL — no ngrok.

| Flag | Default | Purpose |
|---|---|---|
| `--forward-to <url>` | print only | POST each event to a local URL |
| `--filter <glob>` | `*` | match `event_type` (`order.*`, `*.kyc.*`) |
| `--since <dur\|iso>` | now | replay from `5m`, `1h`, or an ISO timestamp |
| `--replay <webhook-id>` | — | send one webhook's test event (exclusive) |
| `--signing-secret <s>` | `$BUILDMARKETS_WEBHOOK_SECRET` | HMAC for the forwarded signature |
| `--pretty` / `--json` | per TTY | output format |

```bash
bm webhooks tail
bm webhooks tail --forward-to http://localhost:4242/webhooks --filter 'order.*'
```

### `bm logs tail`
Live API request logs for your tenant. Filters AND together.

| Flag | Purpose |
|---|---|
| `--account <id>` | filter by account |
| `--method <verb>` | GET/POST/PUT/PATCH/DELETE |
| `--status <code\|class>` | `404`, or `4xx`/`5xx`/`2xx` |
| `--path <glob>` | e.g. `/v1/accounts/*` |
| `--since <dur\|iso>` | from this point |

```bash
bm logs tail --method POST --status 4xx --path '/v1/accounts/*'
```

### `bm dev sandbox reset`
Wipe + reseed a sandbox tenant. **Refuses to run against a live key.**

| Flag | Default | Purpose |
|---|---|---|
| `--seed <minimal\|full>` | `minimal` | fixture set |
| `--yes` | false | skip confirmation |

```bash
bm dev sandbox reset --seed full --yes
```

### `bm migrate from-alpaca`
Two-phase Alpaca Broker API → Buildmarkets migration: **plan → apply**, journaled
and resumable.

```bash
# 1. Generate a reviewable plan (reads Alpaca, writes nothing to Buildmarkets):
bm migrate from-alpaca plan \
  --alpaca-key   $ALPACA_API_KEY_ID \
  --alpaca-secret $ALPACA_API_SECRET_KEY \
  --output ./buildmarkets-plan.json

# 2. Review the plan + warnings, then apply (resumable):
bm migrate from-alpaca apply ./buildmarkets-plan.json
bm migrate from-alpaca apply ./buildmarkets-plan.json --resume   # after an interruption

# 3. Inspect progress anytime:
bm migrate status ./buildmarkets-plan.json
```

| `plan` flag | Default | Purpose |
|---|---|---|
| `--alpaca-key` / `--alpaca-secret` | env `ALPACA_API_KEY_ID`/`ALPACA_API_SECRET_KEY` | source auth |
| `--alpaca-base-url` | `https://api.alpaca.markets` | paper/live override |
| `--account` | all | scope to one Alpaca account |
| `--include` | all types | `accounts,positions,orders,watchlists,ach_relationships,transfers` |
| `--output` | `./buildmarkets-plan.json` | plan file path |
| `--dry-run` | false | print summary, write nothing |

| `apply` flag | Purpose |
|---|---|
| `--resume` | skip steps already COMPLETED/SKIPPED |
| `--from-step <id>` | begin at a step |
| `--skip-step <id>` | skip a step (repeatable) |
| `--parallel <N>` | run independent steps concurrently |
| `--continue-on-error` | don't stop on a failed step |

> Positions can't migrate via API (ACAT is a real-world process) — the plan emits
> a customer-decision warning. ACH relationships need re-linking via Plaid.
> Apply uses an idempotency key per step, so re-runs are safe.

---

## Scripting recipes

```bash
# CI: non-interactive, JSON, fail the job on error (exit codes propagate)
export BUILDMARKETS_NON_INTERACTIVE=1
bm marketdata quote AAPL --json | jq -er '.data.lastPrice'

# Pipe a list into jq
bm accounts list --json | jq -r '.data[].account_number'

# Place an order from a script and capture the order id
oid=$(bm orders place --account "$ACC" --symbol AAPL --side buy --qty 1 --json | jq -r '.id')

# Stream order fills live (NDJSON off a TTY)
bm orders list --account "$ACC" --watch --json | while read -r line; do echo "$line" | jq .; done
```

---

*This guide is hand-maintained. The per-command reference in
[`docs/COMMAND_REFERENCE.md`](./COMMAND_REFERENCE.md) is generated from the binary with
`make docs` and is always authoritative for exact flags.*
