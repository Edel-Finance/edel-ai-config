# Edel PERPS public capabilities

This file is an index, not a contract. Each row names the public MCP tool, the REST route it
calls, the API key scope and the docs page that owns the facts. Before you use a row, open its
docs page and the route description in the live `GET <REST origin>/openapi.json`. Limits,
fields, statuses and error codes live there. Do not copy them from here or from memory.

The CI check in this repo fails when a tool named here is missing from the live MCP tools docs
page (<https://docs.edel.finance/developers/mcp/tools>) or a route named here is missing from the
live TestNet `GET /openapi.json`. A capability that is absent from the live contract of your venue
is unavailable there.

Docs root: <https://docs.edel.finance/developers/overview>.

## Surfaces

| Surface | What it is | Docs |
| --- | --- | --- |
| REST `/v1` | The native API. Every capability below. | <https://docs.edel.finance/developers/rest-reference> |
| REST `/v2` | The CCXT wire shape of the same capabilities. | <https://docs.edel.finance/developers/rest-reference> |
| WebSockets | Live market and account channels. Needs a realtime ticket. | <https://docs.edel.finance/developers/realtime-reference> |
| MCP | Hosted tools that call `/v1` with an approved API key. | <https://docs.edel.finance/developers/mcp/tools> |

MCP tools return snapshots, not a feed. The docs say: "For live market and account updates,
use WebSockets." A hosted MCP request needs an approved read-capable key, even for catalogue
tools. The server fills `accountId` from the key.

## Connect and status

| Capability | MCP tool | REST route | Scope | Docs |
| --- | --- | --- | --- | --- |
| Connect an agent (device grant) | `edel_connect` | `POST /v1/agent-connect/start`, `POST /v1/agent-connect/complete` | none | [for-agents](https://docs.edel.finance/developers/accounts/for-agents) |
| Read the current key metadata | `edel_connect` | `GET /v1/api-keys/current` | `read` | [api-keys](https://docs.edel.finance/developers/authentication/api-keys) |
| Account readiness and Party status | `edel_status` | `GET /v1/accounts/{accountId}`, `GET /v1/accounts/{accountId}/party` | `read` | [for-agents](https://docs.edel.finance/developers/accounts/for-agents) |
| Account snapshot | `edel_account` | `GET /v1/accounts/{accountId}` | `read` | [rest-reference](https://docs.edel.finance/developers/rest-reference) |
| Venue state and availability of each action | `edel_system_status` | Not in the live TestNet contract yet. | none | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Read the account's acceptance of the current trading terms | `edel_terms` | Not in the live TestNet contract yet. | `read` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| KYC state | `edel_kyc_status` | `GET /v1/accounts/{accountId}/kyc` | `read` | [kyc-policy](https://docs.edel.finance/developers/accounts/kyc-policy) |
| The owner's own profile (email, sign-in providers, passkeys, KYC, Party, key metadata) | `edel_me` | `GET /v1/me` | `read` | [rest-reference](https://docs.edel.finance/developers/rest-reference) |
| The owner's passkeys and their status in this venue | `edel_passkeys` | `GET /v1/accounts/{accountId}/passkeys` | `read` | [for-humans](https://docs.edel.finance/developers/accounts/for-humans) |

## Markets

| Capability | MCP tool | REST route | Scope | Docs |
| --- | --- | --- | --- | --- |
| Market catalogue | `edel_markets` | `GET /v1/markets` | none | [rest-reference](https://docs.edel.finance/developers/rest-reference) |
| One market | `edel_market` | `GET /v1/markets/{marketId}` | none | same |
| Stats and book snapshot | `edel_price` | `GET /v1/markets/{marketId}/stats`, `GET /v1/markets/{marketId}/book` | none | same |
| Ticker snapshots for all or selected markets (CCXT shape) | `edel_market_tickers` | Not in the live TestNet contract yet. | none | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Venue open interest, 24h volume and mean funding rates per settlement asset | `edel_venue_totals` | Not in the live TestNet contract yet. | none | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Candles | `edel_candles` | `GET /v1/markets/{marketId}/candles` | none | same |
| Candidate markets | `edel_candidate_markets` | `GET /v1/market-data/candidate-markets` | none | same |
| Leaderboard | `edel_leaderboard` | `GET /v1/leaderboard` | none | same |
| Affiliate availability | `edel_affiliate_availability` | `GET /v1/affiliate/availability` | none | same |
| Recent public trades of one market (CCXT shape) | `edel_market_trades` | `GET /v2/markets/{symbol}/trades` | none | same |

## Orders and positions

| Capability | MCP tool | REST route | Scope | Docs |
| --- | --- | --- | --- | --- |
| Preview an order | `edel_preview_order` | `POST /v1/orders/preview` | `read` | [rest-reference](https://docs.edel.finance/developers/rest-reference) |
| Place an order | `edel_place_order` | `POST /v1/orders` | `trade` | same |
| Place a batch | `edel_place_order_batch` | `POST /v1/orders/batch` | `trade` | same |
| Read one order | `edel_order` | `GET /v1/orders/{orderId}` | `read` | same |
| Cancel an order | `edel_cancel_order` | `POST /v1/orders/{orderId}/cancel` | `trade` | same |
| Cancel a batch | `edel_cancel_order_batch` | `POST /v1/orders/batch/cancel` | `trade` | same |
| Cancel every open order of one market (CCXT shape) | `edel_cancel_all_orders` | `POST /v2/orders/cancel-all` | `trade` | same |
| Open orders | `edel_orders` | `GET /v1/accounts/{accountId}/orders/open` | `read` | same |
| Open positions | `edel_positions` | `GET /v1/accounts/{accountId}/positions` | `read` | same |
| Close a position | `edel_close_position` | `GET /v1/accounts/{accountId}/positions`, `POST /v1/orders` | `trade` | [for-agents](https://docs.edel.finance/developers/accounts/for-agents) |
| Order history | `edel_order_history` | `GET /v1/accounts/{accountId}/orders` | `read` | same |
| Fill history | `edel_trade_history` | `GET /v1/accounts/{accountId}/fills` | `read` | same |
| Position history | `edel_position_history` | `GET /v1/accounts/{accountId}/positions/history` | `read` | same |
| Funding paid per position | `edel_funding` | `GET /v1/accounts/{accountId}/positions/history` | `read` | same |

From [for-agents](https://docs.edel.finance/developers/accounts/for-agents):

> Take profit and stop loss travel as `autoClose` (`takeProfitPriceAtoms`, `stopLossPriceAtoms`)
> on `edel_place_order` and on each `edel_place_order_batch` entry. The public contract has no
> standalone trigger arm, cancel or replace route and no `timeInForce` on `/v1`, so no tool
> offers them.

> `fundingPaidAtoms` is cumulative funding paid per episode. It is not per-payment funding
> history; the API does not serve that ledger, and this tool never invents payment rows.

## Deposits and withdrawals

A key with the opt-in `funding` scope starts, reads and advances these flows. It never signs.
When the owner must sign, the answer is `owner_signature_required` and the owner signs in the
browser. Each money action needs separate owner permission.

| Capability | MCP tool | REST route | Scope | Docs |
| --- | --- | --- | --- | --- |
| Test funds (Development only) | `edel_faucet_grant` | `POST /v1/accounts/{accountId}/faucet-grant` | `funding` | [for-agents](https://docs.edel.finance/developers/accounts/for-agents) |
| Funding intents | `edel_funding_intents` | `GET /v1/accounts/{accountId}/local-signing-funding-intents` | `funding` | same |
| xReserve deposit inputs (USDC bridged to USDCx) | `edel_xreserve_deposit` | `GET /v1/accounts/{accountId}/xreserve-deposit` | see the route | same |
| Start a deposit | `edel_deposit` | `POST /v1/accounts/{accountId}/deposits` | `funding` | same |
| Advance a deposit | `edel_deposit_confirm` | `POST /v1/accounts/{accountId}/deposits/confirm` | `funding` | same |
| Request a withdrawal | `edel_withdraw` | `GET /v1/accounts/{accountId}/party`, `POST /v1/withdrawals` | `funding` | same |
| Read a withdrawal | `edel_withdrawal` | `GET /v1/withdrawals/{withdrawalId}` | `funding` | same |
| Advance a withdrawal | `edel_withdrawal_confirm` | `POST /v1/withdrawals/{withdrawalId}/confirm` | `funding` | same |
| Settle a withdrawal | `edel_withdrawal_settle` | `GET /v1/withdrawals/{withdrawalId}`, `POST /v1/withdrawals/{withdrawalId}/authorize` | `funding` | same |
| Transfer history | `edel_transfers` | `GET /v1/accounts/{accountId}/transfers` | `funding` | same |

Which deposit path a venue offers is in its live contract and in
[for-humans](https://docs.edel.finance/developers/accounts/for-humans):

- Development: test funds with `edel_faucet_grant`.
- Where the collateral is USDCx: `edel_deposit` moves an exact amount of the USDCx the owner's
  Party already holds, then `edel_deposit_confirm` advances it. The owner signs once.
- USDC from Ethereum through Circle's xReserve bridge: `edel_xreserve_deposit` returns where the
  Party stands with the bridge and, once the bridge agreement exists, the deposit inputs for that
  venue. The USDC becomes USDCx only after the owner signs the mint
  (`POST /v1/accounts/{accountId}/xreserve-deposit/mint`) in the browser. A key never reaches it.

## Strategy agents

From the `agents` scope row of [for-agents](https://docs.edel.finance/developers/accounts/for-agents#what-a-key-can-do):

> Opt-in, never requested by default, and only a key the owner approved with a passkey through
> agent connect may hold it; a bot key cannot. [...] Agents run in paper mode only: they place no
> venue order and move no funds, and the scope adds no trading.

Read each route description in the live OpenAPI document for its limits and the venues that
offer it.

| Capability | MCP tool | REST route | Scope | Docs |
| --- | --- | --- | --- | --- |
| Strategy catalogue | `edel_agent_strategies` | `GET /v1/agents/strategies` | none | [rest-reference](https://docs.edel.finance/developers/rest-reference) |
| Historical money estimate per strategy | `edel_agent_money_estimates` | `GET /v1/agents/strategy-estimates` | none | same |
| Net profit or required deposit for one strategy and market | `edel_agent_estimate_scenario` | `POST /v1/agents/strategy-estimate-scenarios` | none | same |
| Models an agent can use, with their cost | `edel_agent_models` | `GET /v1/agents/models` | none | same |
| What auto market selection uses | `edel_agent_market_selection` | `GET /v1/agents/market-selection` | none | same |
| Draft Pine from plain English | `edel_agent_pine` | `POST /v1/accounts/{accountId}/agents/pine` | `agents` | same |
| Backtest with a probability estimate | `edel_agent_backtest` | `POST /v1/accounts/{accountId}/agents/backtest` | `agents` | same |
| Deploy a paper agent | `edel_agent_deploy` | `POST /v1/accounts/{accountId}/agents` | `agents` | same |
| List agents | `edel_agents` | `GET /v1/accounts/{accountId}/agents` | `agents` | same |
| Pause, resume, start, stop, delete | `edel_agent_command` | `POST /v1/accounts/{accountId}/agents/{deploymentId}/pause`, `POST /v1/accounts/{accountId}/agents/{deploymentId}/resume`, `POST /v1/accounts/{accountId}/agents/{deploymentId}/activate`, `POST /v1/accounts/{accountId}/agents/{deploymentId}/stop`, `DELETE /v1/accounts/{accountId}/agents/{deploymentId}` | `agents` | same |
| Choose the model | `edel_agent_model` | `PUT /v1/accounts/{accountId}/agents/{deploymentId}/model` | `agents` | same |
| Rename an agent | `edel_agent_rename` | Not in the live contract yet. | `agents` | same |
| Send a message to an agent | `edel_agent_chat` | Not in the live contract yet. | `agents` | same |
| List preset questions for agent chat | `edel_agent_chat_presets` | Not in the live TestNet contract yet. | none | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Read an agent's chat messages | `edel_agent_chat_messages` | Not in the live contract yet. | `agents` | same |
| Close all positions of an owned, paused or stopped live agent with reduce-only market orders, with owner approval | `edel_agent_close` | Not in the live TestNet contract yet. | `agents` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Read the recorded decision behind an owned live agent's fill | `edel_agent_fill_decision` | Not in the live TestNet contract yet. | `agents` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Read an owned agent's deployed Pine v5 code and strategy version | `edel_agent_strategy` | Not in the live TestNet contract yet. | `agents` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Action log and paper PnL | `edel_agent_actions` | `GET /v1/accounts/{accountId}/agents/{deploymentId}/actions` | `agents` | same |
| An agent account's wallet (owner live view) | `edel_agent_wallet` | `GET /v1/accounts/{accountId}/agents/{deploymentId}/wallet` | `agents` | same |
| An agent account's positions (owner live view) | `edel_agent_positions` | `GET /v1/accounts/{accountId}/agents/{deploymentId}/positions` | `agents` | same |
| An agent account's orders (owner live view) | `edel_agent_orders` | `GET /v1/accounts/{accountId}/agents/{deploymentId}/orders` | `agents` | same |
| An agent account's fills (owner live view) | `edel_agent_fills` | `GET /v1/accounts/{accountId}/agents/{deploymentId}/fills` | `agents` | same |
| An agent's protective skills | `edel_agent_skills` | `GET /v1/accounts/{accountId}/agents/{deploymentId}/skills` | `agents` | same |
| An agent's model fees | `edel_agent_fees` | `GET /v1/accounts/{accountId}/agents/{deploymentId}/fees` | `agents` | same |
| Fund your own agent account with test collateral | `edel_agent_fund` | `POST /v1/accounts/{accountId}/agent-accounts/{agentAccountId}/test-funding` | `funding` | same |
| Prepare funding of your own agent account | `edel_agent_fund_prepare` | Not in the live contract yet. | `funding` | same |
| Confirm a prepared agent funding | `edel_agent_fund_confirm` | Not in the live contract yet. | `funding` | same |
| Return funds from an agent account to your account | `edel_agent_withdraw` | Not in the live contract yet. | `funding` | same |

"Not in the live contract yet" means the route is not in the live `/openapi.json` of any
published venue today. Treat it as unavailable. This file names the route when the venue serves it.

The backtest route labels its probability "historical estimate, not a guarantee". Say so when
you report it. The money estimate is a cached historical dollar range, not a forecast; it says
when a strategy has too little history for a number. Report that case, do not invent one.

A deployment runs on one to three listed markets: send `marketSelection` with explicit
`marketIds`, or `auto` to let the named model pick and record its reason. The owner watches
deployments live on the `account.agents` realtime channel.

## CCXT `/v2`

These routes return the same capabilities in the CCXT wire shape. Two have MCP tools,
`edel_market_trades` and `edel_cancel_all_orders` (rows above). For the rest, use the `/v1` twin
through MCP.

- `GET /v2/markets`, `GET /v2/markets/{symbol}/stats`, `GET /v2/markets/{symbol}/candles`,
  `GET /v2/markets/{symbol}/book`
- `GET /v2/accounts/{accountId}`, `GET /v2/accounts/{accountId}/positions`
- `GET /v2/markets/{symbol}/trades`
- `POST /v2/order`, `POST /v2/orders`, `GET /v2/orders/{orderId}`,
  `POST /v2/orders/{orderId}/cancel`, `POST /v2/orders/cancel`, `POST /v2/orders/cancel-all`
- `GET /v2/accounts/{accountId}/orders`, `GET /v2/accounts/{accountId}/orders/open`,
  `GET /v2/accounts/{accountId}/fills`

Routes under `/v2/not-implemented/` always answer `501`. Do not call them.

## Owner only (no tool, no key)

The MCP exclusions table of [for-agents](https://docs.edel.finance/developers/accounts/for-agents) gives the reason for each route. Two rows
cover these:

> The flow needs the owner's passkey, social sign-in or local signing ceremony in a browser,
> which an agent cannot perform.

> The API refuses every API key on this route with 403 passkey_required; widening the key
> allowlist is an owner security decision.

The routes in those rows include login and registration, Party binding
(`POST /v1/accounts/{accountId}/party` and its `complete` and `consent` routes), agent approval,
API key listing and revocation, adding a passkey (`POST /v1/accounts/{accountId}/passkeys`),
the xReserve mint, affiliate earnings and profile, KYC skip and favorites. Do not try to reach them with a key.

## Realtime tickets

`POST /v1/realtime/ticket`, `PUT /v1/realtime/ticket` and `DELETE /v1/realtime/ticket` mint,
rotate and revoke the WebSocket ticket. MCP cannot carry a ticket. Channels are listed in the
[realtime reference](https://docs.edel.finance/developers/realtime-reference).
