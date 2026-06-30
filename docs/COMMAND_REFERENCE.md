# bm — Command Reference

Every command, generated from the CLI itself. `REQUIRED` flags and
positional `<args>` must be provided. Global flags (`--json`, `--table`,
`--non-interactive`, `--yes`, `--debug`, `--watch`, `--api-key`/`--api-secret`)
apply to every command — see [DEVELOPER_GUIDE.md](./DEVELOPER_GUIDE.md).

Regenerate with `make docs`.

---

## bm

Buildmarkets developer CLI

### Synopsis

bm — the Buildmarkets developer CLI.

A thin, scriptable front end to the Buildmarkets brokerage API for humans at
terminals, CI/CD pipelines, and focused-action agents. Talks to the API gateway
directly (never through the MCP).

Auth:
  bm login                         trader  — OAuth device flow (Keycloak)
  bm config set api-key <key>      partner — API key + secret

Output is a table on a TTY and JSON otherwise; use --json/--table to force.

### Options

```
      --api-key string       partner API key (overrides config/env)
      --api-secret string    partner API secret (overrides config/env)
      --debug                verbose logging to stderr
  -h, --help                 help for bm
      --json                 force JSON output
      --no-update-check      skip the auto-update check
      --non-interactive      disable all prompts, color, and animation (for CI/agents)
      --table                force table output
      --watch                poll a read command and re-render on an interval
      --watch-interval int   seconds between --watch polls (min 1) (default 2)
      --yes                  skip confirmation prompts
```

---

## bm accounts

Accounts commands

### Options

```
  -h, --help   help for accounts
```

---

## bm accounts balances

Get balances

### Synopsis

Returns cash balances, buying power, equity, and margin details. Live accounts fetch

```
bm accounts balances <id> [flags]
```

### Options

```
  -h, --help   help for balances
```

---

## bm accounts close

Close account

### Synopsis

Close endpoint. Same as DELETE /v1/accounts/{accountId}.

```
bm accounts close <id> [flags]
```

### Options

```
  -h, --help   help for close
```

---

## bm accounts get

Get account details

```
bm accounts get <id> [flags]
```

### Options

```
  -h, --help   help for get
```

---

## bm accounts list

List all accounts (paginated)

### Synopsis

Returns a slim list of accounts. Use GET /v1/accounts/{accountId} for full details.

```
bm accounts list [flags]
```

### Options

```
      --created-after string    Filter accounts created after this timestamp (inclusive).
      --created-before string   Filter accounts created before this timestamp (inclusive).
      --cursor string           Cursor for pagination (from previous response).
  -h, --help                    help for list
      --limit int               Number of results per page (max 100). (default 25)
      --query string            Space-delimited search tokens. Matches account number, name, email, or phone (logical AND across tokens).
      --sort string             Sort by created_at. Defaults to desc. (one of: asc, desc) (default "desc")
      --status string           Filter by account status. (one of: SUBMITTED, ACTIVE, ACTION_REQUIRED, ACCOUNT_CLOSED)
```

---

## bm accounts open

Open a new brokerage account (interactive KYC or --data)

### Synopsis

Opens a new brokerage account (POST /v1/accounts) with inline KYC.

Two ways to supply the application:
  --interactive   walk through the required fields (default on a TTY)
  --data <json>   provide the full CreateAccountRequest body, inline or @file.json

Sandbox tax_id test paths (deterministic KYC outcomes):
  ending 0001 → approved      ending 0002 → rejected      ending 0003 → manual_review

```
bm accounts open [flags]
```

### Options

```
      --data string   full CreateAccountRequest JSON, inline or @file.json
  -h, --help          help for open
      --interactive   walk through the application interactively
```

---

## bm accounts update

Update account info

### Synopsis

Updates account fields. Updates account fields. Identity fields (name, DOB, tax ID) are only updatable while account is pending.

Supply the request body with --data '<json>' or --data @file.json.

```
bm accounts update <id> [flags]
```

### Options

```
      --data string   JSON request body, inline or @file.json (REQUIRED)
  -h, --help          help for update
```

---

## bm config

Get and set CLI configuration

### Synopsis

Manage ~/.buildmarkets/config.yaml. Environment variables override the
file at runtime (env always wins).

Settable keys:
  environment      sandbox | qa | live
  api-key          partner API key   (stored in OS keychain)
  api-secret       partner API secret (stored in OS keychain)
  api-base-url     override the API gateway URL
  auth-base-url    override the Keycloak base URL
  auth-realm       override the Keycloak realm
  auth-client-id   override the OAuth client id

### Options

```
  -h, --help   help for config
```

---

## bm config get

Get a config value (effective, after env overrides)

```
bm config get <key> [flags]
```

### Options

```
  -h, --help   help for get
```

---

## bm config list

Show all effective config values

```
bm config list [flags]
```

### Options

```
  -h, --help   help for list
```

---

## bm config set

Set a config value

```
bm config set <key> <value> [flags]
```

### Examples

```
  bm config set environment sandbox
  bm config set api-key tapp_sandbox_xxx
  bm config set api-secret sk_xxx
```

### Options

```
  -h, --help   help for set
```

---

## bm dev

Developer utilities

### Options

```
  -h, --help   help for dev
```

---

## bm dev sandbox

Sandbox tenant management

### Options

```
  -h, --help   help for sandbox
```

---

## bm dev sandbox reset

Wipe and reseed a sandbox tenant

### Synopsis

Wipes all data in the sandbox tenant and reseeds with a fixture set.

Backend: POST /v1/dev/sandbox/reset.  [VERIFY-BACKEND]

Refuses to run against a live tenant: if the resolved API key looks live, the
command exits 3 before any network call.

Fixtures:
  minimal  3 accounts (approved/rejected/manual_review), approved funded $10,000
  full     minimal + open orders, ACH relationships, a webhook, sample documents

```
bm dev sandbox reset [flags]
```

### Options

```
  -h, --help          help for reset
      --seed string   fixture set: minimal | full (default "minimal")
      --yes           skip the confirmation prompt
```

---

## bm documents

Documents commands

### Options

```
  -h, --help   help for documents
```

---

## bm documents email

Email Document

### Synopsis

Sends a specified document to a recipient by email.

Set fields via flags, or pass --data '<json>'/@file.json to merge a full body.

```
bm documents email [flags]
```

### Options

```
      --data string           JSON request body to merge, inline or @file.json
      --document-url string   Direct URL to the document to be emailed. Must not be empty.
      --email string          Recipient email address. If omitted, the platform may use defaults.
  -h, --help                  help for email
```

---

## bm documents list

Retrieve Documents

### Synopsis

Retrieves a filtered list of documents. Filter by document type, account number, date (month, year, day), and pagination.

Set fields via flags, or pass --data '<json>'/@file.json to merge a full body.

```
bm documents list [flags]
```

### Options

```
      --account-number string   Filter documents for a specific account.
      --data string             JSON request body to merge, inline or @file.json
      --date int                Day of month (1-31) to narrow results.
      --document-type-id int    Filter by document type.
  -h, --help                    help for list
      --limit int               Maximum number of documents to return.
      --month int               Month (1-12) to filter documents.
      --offset int              Pagination offset (number of items to skip).
      --year int                Year (minimum 1900) to filter documents.
```

---

## bm documents types

List Supported Documents

### Synopsis

Returns the full catalog of document types available within the system.

```
bm documents types [flags]
```

### Options

```
  -h, --help   help for types
```

---

## bm documents upload

Upload an owner document for an account

### Synopsis

Uploads an owner document (POST /v1/accounts/{accountId}/documents/upload).

The file is read locally, base64-encoded, and its MIME type inferred from the
extension unless --mime-type is given.

Example:
  bm documents upload --account <id> --type w8ben --file ./form.pdf

```
bm documents upload [flags]
```

### Options

```
      --account string             REQUIRED — account UUID
      --content-data string        JSON form data for w8ben, inline or @file.json
      --document-sub-type string   free-form sub-classification (e.g. passport)
      --file string                path to the document file (base64-encoded on upload)
  -h, --help                       help for upload
      --mime-type string           MIME type override (inferred from extension by default)
      --type string                REQUIRED — document type (identity_verification, w8ben, w9, ...)
```

---

## bm documents w9

Request W-9 Form

### Synopsis

Generates a W-9 form for a specified user and returns processing status.

```
bm documents w9 [flags]
```

### Options

```
  -h, --help             help for w9
      --user-id string   User identifier (UUID) for the W-9 form.
```

---

## bm funding

Funding commands

### Options

```
  -h, --help   help for funding
```

---

## bm funding ach

Ach commands

### Options

```
  -h, --help   help for ach
```

---

## bm funding ach link

Link a bank account

### Synopsis

Links a bank account via ACH. Profile is auto-approved with third-party verification.

Set fields via flags, or pass --data '<json>'/@file.json to merge a full body.

```
bm funding ach link [flags]
```

### Options

```
      --account string                   REQUIRED — account UUID
      --bank-account-number string       Bank account number. Only last 4 digits stored.
      --bank-account-owner-name string   Account holder name at banking institution.
      --bank-account-type string         Bank account type (DB only) (one of: CHECKING, SAVINGS)
      --bank-name string                 Optional — Bank name (DB only)
      --bank-routing-number string       ABA routing number (9 digits).
      --data string                      JSON request body to merge, inline or @file.json
  -h, --help                             help for link
```

---

## bm funding ach list

List ACH relationships

```
bm funding ach list [flags]
```

### Options

```
      --account string   REQUIRED — account UUID
  -h, --help             help for list
```

---

## bm funding ach remove

Remove ACH relationship

### Synopsis

Removes the ACH bank link and sets status to cancelled.

```
bm funding ach remove <ach-id> [flags]
```

### Options

```
      --account string   REQUIRED — account UUID
  -h, --help             help for remove
```

---

## bm funding activity

List funding activity

```
bm funding activity [flags]
```

### Options

```
      --account string   REQUIRED — account UUID
  -h, --help             help for activity
```

---

## bm funding activity-detail

Get funding details

```
bm funding activity-detail <activity-id> [flags]
```

### Options

```
      --account string   REQUIRED — account UUID
  -h, --help             help for activity-detail
```

---

## bm funding deposit

ACH deposit

### Synopsis

Initiate an ACH deposit (credit) into the brokerage account.

Set fields via flags, or pass --data '<json>'/@file.json to merge a full body.

```
bm funding deposit [flags]
```

### Options

```
      --account string               REQUIRED — account UUID
      --ach string                   ACH relationship ID (must be APPROVED)
      --ach-relationship-id string   ACH relationship ID (must be APPROVED)
      --amount string                Deposit amount (2 decimal places)
      --data string                  JSON request body to merge, inline or @file.json
      --description string           Optional memo
  -h, --help                         help for deposit
```

---

## bm funding withdraw

ACH withdrawal

### Synopsis

Initiate an ACH withdrawal (debit) from the brokerage account. Supports IRA distribution fields for IRA accounts.

Set fields via flags, or pass --data '<json>'/@file.json to merge a full body.

```
bm funding withdraw [flags]
```

### Options

```
      --account string                   REQUIRED — account UUID
      --ach string                       ACH relationship ID
      --ach-relationship-id string       ACH relationship ID
      --amount string                    Withdrawal amount. Required unless withdraw_full_balance is true
      --data string                      JSON request body to merge, inline or @file.json
      --description string               Optional memo
      --fee-amount string                Optional processing fee.
  -h, --help                             help for withdraw
      --ira-distribution-type string     IRA distribution type (for IRA accounts).
      --ira-federal-withholding string   Federal withholding amount.
      --ira-state string                 State for withholding.
      --ira-state-withholding string     State withholding amount.
      --ira-tax-code string              IRA tax code for distribution.
      --ira-year int                     IRA distribution tax year.
      --withdraw-full-balance            Withdraw entire settled cash balance.
```

---

## bm keys

Keys commands

### Options

```
  -h, --help   help for keys
```

---

## bm keys create

Generate a new API key

### Synopsis

Set fields via flags, or pass --data '<json>'/@file.json to merge a full body.

```
bm keys create [flags]
```

### Options

```
      --data string      JSON request body to merge, inline or @file.json
  -h, --help             help for create
      --label string     REQUIRED
      --scopes strings   REQUIRED
```

---

## bm keys list

List all API keys

```
bm keys list [flags]
```

### Options

```
  -h, --help         help for list
      --limit int    Max results to return
      --offset int   Number of records to skip
```

---

## bm keys revoke

Revoke an API key

```
bm keys revoke <key-id> [flags]
```

### Options

```
  -h, --help   help for revoke
```

---

## bm login

Log in as a trader via OAuth device flow

### Synopsis

Starts the OAuth 2.0 device authorization flow against Keycloak.

Prints a verification URL and user code, then polls until you approve in the
browser. The resulting token is stored in the OS keychain (or a 0600 config
file if no keychain is available).

For partner / M2M auth, use an API key instead:
  bm config set api-key <key>
  bm config set api-secret <secret>

```
bm login [flags]
```

### Options

```
  -h, --help   help for login
```

---

## bm logout

Clear stored credentials

```
bm logout [flags]
```

### Options

```
  -h, --help   help for logout
```

---

## bm logs

API request log streaming

### Options

```
  -h, --help   help for logs
```

---

## bm logs tail

Stream API request logs for your tenant

### Synopsis

Streams API request logs for the authenticated tenant.

Backend: GET /v1/logs/stream (SSE).  [VERIFY-BACKEND]
Filters compose with logical AND.

Status filter accepts an exact code (404) or a class (4xx, 5xx, 2xx).

Examples:
  bm logs tail
  bm logs tail --method POST --status 4xx --path '/v1/accounts/*'

```
bm logs tail [flags]
```

### Options

```
      --account string   filter by account id
  -h, --help             help for tail
      --json             force JSON (NDJSON) output
      --method string    filter by HTTP method (GET/POST/PUT/PATCH/DELETE)
      --path string      glob over the request path, e.g. /v1/accounts/*
      --since string     stream from this point (5m, 1h, or ISO 8601)
      --status string    filter by status code (404) or class (4xx/5xx/2xx)
```

---

## bm marketdata

Marketdata commands

### Options

```
  -h, --help   help for marketdata
```

---

## bm marketdata balance-sheet

Balance sheet

### Synopsis

Financial statements. Symbol can be ticker or *CUSIP/*ISIN (e.g. *US02079K3059).

```
bm marketdata balance-sheet <symbol> [flags]
```

### Options

```
  -h, --help                    help for balance-sheet
      --number-of-reports int   Number of reports to return (e.g. 5 annual = last 5 years) (default 5)
      --statement-type string   Annual or quarterly reports (one of: annual, quarterly) (default "annual")
```

---

## bm marketdata dividends

Cash dividends

### Synopsis

Dividend history. Symbol can be ticker or *CUSIP/*ISIN.

```
bm marketdata dividends <symbol> [flags]
```

### Options

```
      --excluding-from string   Start date filter (format: YYYY-MM-DD)
      --excluding-to string     End date filter (format: YYYY-MM-DD). Must be used with excludingFrom.
  -h, --help                    help for dividends
```

---

## bm marketdata historical

Historical data

### Synopsis

EOD OHLCV bars from QuoteMedia

```
bm marketdata historical <symbol> [flags]
```

### Options

```
      --end-date string     
      --from string         
  -h, --help                help for historical
      --start-date string   
      --to string           
```

---

## bm marketdata industries

All industries

```
bm marketdata industries [flags]
```

### Options

```
  -h, --help   help for industries
```

---

## bm marketdata logo

Stock logo

```
bm marketdata logo <symbol> [flags]
```

### Options

```
  -h, --help   help for logo
```

---

## bm marketdata news

News & corporate actions

```
bm marketdata news <symbol> [flags]
```

### Options

```
  -h, --help        help for news
      --limit int    (default 50)
```

---

## bm marketdata options

Options commands

### Options

```
  -h, --help   help for options
```

---

## bm marketdata options chain

Get options chain

### Synopsis

Returns every active option contract (calls and puts) for the given underlying symbol on the requested expiration date, sorted by strike. Quotes and Greeks are not included in this response. If the underlying has no listed options, the request fails with 400 NON_OPTIONABLE_TICKER.

```
bm marketdata options chain [flags]
```

### Options

```
      --expiration string   Expiration date in YYYY-MM-DD format.
  -h, --help                help for chain
      --symbol string       Underlying equity symbol (e.g. AAPL).
```

---

## bm marketdata options expirations

Get options expirations

### Synopsis

Returns the distinct expiration dates available for the given underlying symbol, sorted chronologically. Each entry includes the contract type (weekly, monthly, etc.) and, when strikes=true is supplied, the count of distinct strikes at that expiration.

```
bm marketdata options expirations [flags]
```

### Options

```
  -h, --help            help for expirations
      --strikes         When true, each expiration includes a strike_count field.
      --symbol string   Underlying equity symbol.
```

---

## bm marketdata options lookup

Lookup option symbols

### Synopsis

Returns every active option symbol for one or more underlying tickers, grouped by underlying. Use this to enumerate contracts before requesting per-contract details. Up to 30 underlyings can be supplied per request as a comma-separated list. If every supplied underlying is non-optionable, the request fails with 400 NON_OPTIONABLE_TICKER. Partial matches are returned successfully with the unmatched underlyings listed under non_optionable_symbols.

```
bm marketdata options lookup [flags]
```

### Options

```
  -h, --help                help for lookup
      --underlying string   Underlying equity symbol, or comma-separated list of up to 30 (e.g. AAPL or AAPL,MSFT).
```

---

## bm marketdata options strikes

Get options strikes

### Synopsis

Returns the distinct strike prices available for the given underlying symbol on the requested expiration date, sorted numerically. Use this to power a strike picker without paying for the full chain payload.

```
bm marketdata options strikes [flags]
```

### Options

```
      --expiration string   Expiration date in YYYY-MM-DD format.
  -h, --help                help for strikes
      --symbol string       Underlying equity symbol.
```

---

## bm marketdata profile

Company profile

### Synopsis

Company details including market cap, P/E, sector, description

```
bm marketdata profile <symbol> [flags]
```

### Options

```
  -h, --help   help for profile
```

---

## bm marketdata quote

Real-time price

### Synopsis

Live bid/ask/last from market data feed

```
bm marketdata quote <symbol> [flags]
```

### Options

```
  -h, --help   help for quote
```

---

## bm marketdata sector-symbols

Symbols by sector

### Synopsis

Set fields via flags, or pass --data '<json>'/@file.json to merge a full body.

```
bm marketdata sector-symbols [flags]
```

### Options

```
      --data string          JSON request body to merge, inline or @file.json
  -h, --help                 help for sector-symbols
      --limit int            
      --offset int           
      --sector-name string   
```

---

## bm marketdata sectors

All sectors

```
bm marketdata sectors [flags]
```

### Options

```
  -h, --help   help for sectors
```

---

## bm marketdata securities

Equity security master

### Synopsis

Search equity instruments with pagination

Set fields via flags, or pass --data '<json>'/@file.json to merge a full body.

```
bm marketdata securities [flags]
```

### Options

```
      --data string     JSON request body to merge, inline or @file.json
  -h, --help            help for securities
      --limit int       
      --offset int      
      --symbol string   
```

---

## bm marketdata symbol-details

Symbol details

### Synopsis

Set fields via flags, or pass --data '<json>'/@file.json to merge a full body.

```
bm marketdata symbol-details [flags]
```

### Options

```
      --data string       JSON request body to merge, inline or @file.json
  -h, --help              help for symbol-details
      --symbols strings   REQUIRED
```

---

## bm migrate

Migrate from another brokerage to Buildmarkets

### Options

```
  -h, --help   help for migrate
```

---

## bm migrate from-alpaca

Plan and apply a migration from the Alpaca Broker API

### Options

```
  -h, --help   help for from-alpaca
```

---

## bm migrate from-alpaca apply

Execute a migration plan (resumable, journaled)

```
bm migrate from-alpaca apply <plan-file> [flags]
```

### Options

```
      --continue-on-error   don't stop on a failed step
      --from-step string    begin at this step id (skips earlier steps)
  -h, --help                help for apply
      --parallel int        execute independent steps concurrently (default 1)
      --resume              skip steps already COMPLETED/SKIPPED in the journal
      --skip-step strings   mark a step SKIPPED without executing (repeatable)
      --yes                 skip the confirmation prompt
```

---

## bm migrate from-alpaca plan

Read Alpaca state and generate a reviewable migration plan

```
bm migrate from-alpaca plan [flags]
```

### Options

```
      --account string           scope to a single Alpaca account id
      --alpaca-base-url string   Alpaca Broker API base URL (default "https://api.alpaca.markets")
      --alpaca-key string        Alpaca API key id (or $ALPACA_API_KEY_ID)
      --alpaca-secret string     Alpaca secret key (or $ALPACA_API_SECRET_KEY)
      --dry-run                  print the summary without writing a file
  -h, --help                     help for plan
      --include string           comma-separated resource types to plan (default "accounts,positions,orders,watchlists,ach_relationships,transfers")
      --output string            where to write the plan file (default "./buildmarkets-plan.json")
```

---

## bm migrate status

Show a migration plan's progress

```
bm migrate status <plan-file> [flags]
```

### Options

```
  -h, --help   help for status
```

---

## bm orders

Orders commands

### Options

```
  -h, --help   help for orders
```

---

## bm orders cancel

Cancel order

```
bm orders cancel <order-id> [flags]
```

### Options

```
      --account string   REQUIRED — account UUID
  -h, --help             help for cancel
```

---

## bm orders cancel-all

Cancel every open order for an account (bulk-destructive)

### Synopsis

Lists open orders for the account, confirms, then cancels each. Confirmation is required in interactive mode (spec §3).

```
bm orders cancel-all [flags]
```

### Options

```
      --account string   REQUIRED — account UUID
  -h, --help             help for cancel-all
```

---

## bm orders executions

Get execution reports (fills)

```
bm orders executions <order-id> [flags]
```

### Options

```
      --account string   REQUIRED — account UUID
  -h, --help             help for executions
```

---

## bm orders get

Get order details

```
bm orders get <order-id> [flags]
```

### Options

```
      --account string   REQUIRED — account UUID
  -h, --help             help for get
```

---

## bm orders list

List orders

```
bm orders list [flags]
```

### Options

```
      --account string   REQUIRED — account UUID
  -h, --help             help for list
```

---

## bm orders modify

Modify an open order

### Synopsis

Set fields via flags, or pass --data '<json>'/@file.json to merge a full body.

```
bm orders modify <order-id> [flags]
```

### Options

```
      --account string       REQUIRED — account UUID
      --data string          JSON request body to merge, inline or @file.json
  -h, --help                 help for modify
      --limit-price string   
      --qty string           
      --quantity string      
```

---

## bm orders place

Place an order

### Synopsis

Set fields via flags, or pass --data '<json>'/@file.json to merge a full body.

```
bm orders place [flags]
```

### Options

```
      --account string           REQUIRED — account UUID
      --asset-class string       (one of: equity, etf) (default "equity")
      --client-order-id string   REQUIRED — Unique client-generated order identifier (idempotency key)
      --data string              JSON request body to merge, inline or @file.json
      --extended-hours           
  -h, --help                     help for place
      --limit-price string       
      --notional string          
      --order-type string        (one of: market, limit) (default "market")
      --qty string               
      --quantity string          
      --side string              (one of: buy, sell)
      --symbol string            REQUIRED
      --time-in-force string     (one of: day, gtc, opg, cls, ioc, fok) (default "day")
      --type string              (one of: market, limit) (default "market")
```

---

## bm positions

Positions commands

### Options

```
  -h, --help   help for positions
```

---

## bm positions close-all

Liquidate every open position for an account (bulk-destructive)

### Synopsis

Lists open positions and places an offsetting market order to close each. Confirmation is required in interactive mode (spec §3).

```
bm positions close-all [flags]
```

### Options

```
      --account string   REQUIRED — account UUID
  -h, --help             help for close-all
```

---

## bm positions get

Get position by symbol

### Synopsis

Returns position with real-time price and unrealized P&L.

```
bm positions get <symbol> [flags]
```

### Options

```
      --account string   REQUIRED — account UUID
  -h, --help             help for get
```

---

## bm positions list

Get all open positions

### Synopsis

Returns positions with real-time prices and unrealized P&L.

```
bm positions list [flags]
```

### Options

```
      --account string   REQUIRED — account UUID
  -h, --help             help for list
```

---

## bm sandbox

Sandbox helpers

### Options

```
  -h, --help   help for sandbox
```

---

## bm sandbox test-paths

List deterministic sandbox test paths

### Synopsis

Fetches the sandbox test-path catalog from GET /v1/dev/sandbox/test-paths.

If the endpoint is unreachable, falls back to the hard-coded list shipped in
this binary (updated each release):
  tax_id ending 0001 → approved
  tax_id ending 0002 → rejected
  tax_id ending 0003 → manual_review

```
bm sandbox test-paths [flags]
```

### Options

```
  -h, --help   help for test-paths
```

---

## bm system

System commands

### Options

```
  -h, --help   help for system
```

---

## bm system health

API health check

```
bm system health [flags]
```

### Options

```
  -h, --help   help for health
```

---

## bm system live

Liveness check

```
bm system live [flags]
```

### Options

```
  -h, --help   help for live
```

---

## bm system metrics

Latency metrics

```
bm system metrics [flags]
```

### Options

```
  -h, --help   help for metrics
```

---

## bm system ready

Readiness check

```
bm system ready [flags]
```

### Options

```
  -h, --help   help for ready
```

---

## bm version

Print version information

```
bm version [flags]
```

### Options

```
  -h, --help   help for version
```

---

## bm webhooks

Webhooks commands

### Options

```
  -h, --help   help for webhooks
```

---

## bm webhooks create

Create webhook endpoint

### Synopsis

Register a URL to receive webhook events. Pass an empty events array to subscribe to all events.

Set fields via flags, or pass --data '<json>'/@file.json to merge a full body.

```
bm webhooks create [flags]
```

### Options

```
      --data string      JSON request body to merge, inline or @file.json
      --events strings   Event types to subscribe to (empty array = all events)
  -h, --help             help for create
      --url string       HTTPS URL to receive webhooks
```

---

## bm webhooks delete

Delete webhook

```
bm webhooks delete <webhook-id> [flags]
```

### Options

```
  -h, --help   help for delete
```

---

## bm webhooks deliveries

List delivery attempts

```
bm webhooks deliveries <webhook-id> [flags]
```

### Options

```
  -h, --help   help for deliveries
```

---

## bm webhooks get

Get webhook

```
bm webhooks get <webhook-id> [flags]
```

### Options

```
  -h, --help   help for get
```

---

## bm webhooks list

List webhooks

```
bm webhooks list [flags]
```

### Options

```
  -h, --help   help for list
```

---

## bm webhooks tail

Stream webhook events to your terminal or a local URL

### Synopsis

Forwards webhook events from your Buildmarkets tenant to the terminal (or a
local URL via --forward-to) so you can test handlers without a tunnel.

Backend: GET /v1/webhooks/stream (SSE).  [VERIFY-BACKEND]

Examples:
  bm webhooks tail
  bm webhooks tail --forward-to http://localhost:4242/webhooks
  bm webhooks tail --filter 'order.*' --since 1h

```
bm webhooks tail [flags]
```

### Options

```
      --filter string           glob over event_type (e.g. account.*, order.filled) (default "*")
      --forward-to string       POST each event to this local URL
  -h, --help                    help for tail
      --json                    force JSON (NDJSON) output
      --pretty                  force human-readable output
      --replay string           replay a single webhook's test event by webhook id (exclusive)
      --signing-secret string   HMAC secret for the forwarded signature header (or $BUILDMARKETS_WEBHOOK_SECRET)
      --since string            replay from this point (5m, 1h, or ISO 8601)
```

---

## bm webhooks test

Send test event

```
bm webhooks test <webhook-id> [flags]
```

### Options

```
  -h, --help   help for test
```

---

## bm webhooks update

Update webhook

### Synopsis

Set fields via flags, or pass --data '<json>'/@file.json to merge a full body.

```
bm webhooks update <webhook-id> [flags]
```

### Options

```
      --data string      JSON request body to merge, inline or @file.json
      --events strings   
  -h, --help             help for update
      --status string    
      --url string       
```

---

## bm whoami

Print the current authentication identity

```
bm whoami [flags]
```

### Options

```
  -h, --help   help for whoami
```

---

