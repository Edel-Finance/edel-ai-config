# Edel public capabilities (v2)

This file is an index, not a contract. Each row names the public MCP tool, the REST `/v2` route it
calls, the API key scope and the docs page that owns the facts. Before you use a row, open its
docs page and the route description in the live `GET <REST origin>/openapi.json`. Limits,
fields, statuses and error codes live there. Do not copy them from here or from memory.

The CI check in this repo fails when a tool named here is missing from the live MCP tools docs
page (<https://docs.edel.finance/developers/mcp/tools>) or a route named here is missing from the
live TestNet `GET /openapi.json`. A capability that is absent from the live contract of your venue
is unavailable there. MainNet, TestNet and Development can serve different route sets: read the
`/openapi.json` of the venue you use.

Docs root: <https://docs.edel.finance/developers/overview>.

## Surfaces

| Surface | What it is | Docs |
| --- | --- | --- |
| REST `/v2` | The public API for Spot, Perps, Common and Organizations/Partners (CCXT wire shape). | <https://docs.edel.finance/developers/rest-reference> |
| WebSockets | Live market and account channels. Needs a realtime ticket. | <https://docs.edel.finance/developers/realtime-reference> |
| MCP | Hosted tools over the public `/v2` API with an approved API key. | <https://docs.edel.finance/developers/mcp/tools> |

MCP tools return snapshots, not a feed. The docs say: "For live market and account updates,
use WebSockets." A hosted MCP request needs an approved read-capable key, even for catalogue
tools. The server fills `accountId` from the key.

## Connect and status

| Capability | MCP tool | REST route | Scope | Docs |
| --- | --- | --- | --- | --- |
| Connect an agent (device grant) | `edel_connect` | `POST /v2/agent-connect/start`, `POST /v2/agent-connect/complete` | none | [for-agents](https://docs.edel.finance/developers/accounts/for-agents) |
| Read the current key metadata | `edel_connect` | `GET /v2/api-keys/current` | `read` | [api-keys](https://docs.edel.finance/developers/authentication/api-keys) |
| Account readiness and Party status | `edel_status` | `GET /v2/accounts/{accountId}`, `GET /v2/accounts/{accountId}/party` | `read` | [for-agents](https://docs.edel.finance/developers/accounts/for-agents) |
| Account snapshot | `edel_account` | `GET /v2/accounts/{accountId}` | `read` | [rest-reference](https://docs.edel.finance/developers/rest-reference) |
| Account balance (CCXT shape) | `edel_fetch_balance` | `GET /v2/accounts/{accountId}` | `read` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Portfolio equity and PnL history | `edel_portfolio_history` | `GET /v2/accounts/{accountId}/portfolio/history` | `read` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Venue state and availability of each action | `edel_system_status` | `GET /v2/system/status` | none | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Read the account's acceptance of the current trading terms | `edel_terms` | `GET /v2/accounts/{accountId}/terms` | `read` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| The owner's own profile (email, sign-in providers, passkeys, Party, key metadata) | `edel_me` | `GET /v2/me` | `read` | [rest-reference](https://docs.edel.finance/developers/rest-reference) |
| The owner's passkeys and their status in this venue | `edel_passkeys` | `GET /v2/accounts/{accountId}/passkeys` | `read` | [for-humans](https://docs.edel.finance/developers/accounts/for-humans) |
| The account's fee tier | `edel_fee_tier` | `GET /v2/accounts/{accountId}/fee-tier` | `read` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Trading fees for Spot and Perps (CCXT shape) | `edel_fetch_trading_fees` | `GET /v2/spot/trading-fees`, `GET /v2/perps/trading-fees` | `read` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| The account's active campaigns | `edel_campaigns` | `GET /v2/accounts/{accountId}/campaigns` | `read` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| The account's campaign earnings | `edel_campaign_earnings` | `GET /v2/accounts/{accountId}/campaign-earnings` | `read` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |

## Markets (Spot and Perps)

| Capability | MCP tool | REST route | Scope | Docs |
| --- | --- | --- | --- | --- |
| Fetch Spot and Perps markets (CCXT shape) | `edel_fetch_markets` | `GET /v2/spot/markets`, `GET /v2/perps/markets` | none | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Market catalogue | `edel_markets` | `GET /v2/markets` | none | [rest-reference](https://docs.edel.finance/developers/rest-reference) |
| Supported currencies (CCXT shape) | `edel_fetch_currencies` | `GET /v2/currencies` | none | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| One market | `edel_market` | `GET /v2/markets/{marketId}` | none | [rest-reference](https://docs.edel.finance/developers/rest-reference) |
| Upcoming markets | `edel_upcoming_markets` | `GET /v2/markets/upcoming` | none | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Stats and book snapshot | `edel_price` | `GET /v2/markets/{symbol}/stats`, `GET /v2/markets/{symbol}/book` | none | [rest-reference](https://docs.edel.finance/developers/rest-reference) |
| Order book for Spot or Perps (CCXT shape) | `edel_fetch_order_book` | `GET /v2/spot/markets/{symbol}/book`, `GET /v2/perps/markets/{symbol}/book` | none | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Single market ticker for Spot or Perps (CCXT shape) | `edel_fetch_ticker` | `GET /v2/spot/markets/{symbol}/stats`, `GET /v2/perps/markets/{symbol}/stats` | none | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Tickers for Spot or Perps markets (CCXT shape) | `edel_fetch_tickers` | `GET /v2/spot/tickers`, `GET /v2/perps/tickers` | none | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Ticker snapshots for all or selected markets (CCXT shape) | `edel_market_tickers` | `GET /v2/tickers` | none | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Recent public trades for Spot or Perps (CCXT shape) | `edel_fetch_trades` | `GET /v2/spot/markets/{symbol}/trades`, `GET /v2/perps/markets/{symbol}/trades` | none | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Recent public trades of one market (CCXT shape) | `edel_market_trades` | `GET /v2/markets/{symbol}/trades` | none | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| OHLCV candles for Spot or Perps (CCXT shape) | `edel_fetch_ohlcv` | `GET /v2/spot/markets/{symbol}/candles`, `GET /v2/perps/markets/{symbol}/candles` | none | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Candles | `edel_candles` | `GET /v2/markets/{symbol}/candles` | none | [rest-reference](https://docs.edel.finance/developers/rest-reference) |
| Venue open interest, 24h volume and mean funding rates per settlement asset | `edel_venue_totals` | `GET /v2/venue/totals` | none | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Venue collateral units (CCXT shape) | `edel_venue_collateral` | `GET /v2/venue/collateral` | none | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Candidate markets | `edel_candidate_markets` | `GET /v2/market-data/candidate-markets` | none | [rest-reference](https://docs.edel.finance/developers/rest-reference) |
| Leaderboard | `edel_leaderboard` | `GET /v2/leaderboard` | none | [rest-reference](https://docs.edel.finance/developers/rest-reference) |
| Affiliate availability | `edel_affiliate_availability` | `GET /v2/affiliate/availability` | none | [rest-reference](https://docs.edel.finance/developers/rest-reference) |
| Check referral code status | `edel_referral_code_status` | `GET /v2/affiliate/referral-codes/{code}` | none | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| The published fee ladder | `edel_fee_ladder` | `GET /v2/fee-tiers` | none | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |

## Orders and positions (Spot and Perps)

| Capability | MCP tool | REST route | Scope | Docs |
| --- | --- | --- | --- | --- |
| Preview an order | `edel_preview_order` | `POST /v2/orders/preview` | `read` | [rest-reference](https://docs.edel.finance/developers/rest-reference) |
| Create a Spot or Perps order (CCXT shape) | `edel_create_order` | `POST /v2/spot/order`, `POST /v2/perps/order` | `trade` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Create a Spot TWAP order | `edel_create_twap_order` | `POST /v2/spot/twap-orders` | `trade` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Place an order | `edel_place_order` | `POST /v2/order` | `trade` | [rest-reference](https://docs.edel.finance/developers/rest-reference) |
| Place a batch | `edel_place_order_batch` | `POST /v2/orders` | `trade` | [rest-reference](https://docs.edel.finance/developers/rest-reference) |
| Fetch one Spot or Perps order (CCXT shape) | `edel_fetch_order` | `GET /v2/spot/orders/{orderId}`, `GET /v2/perps/orders/{orderId}` | `read` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Read one order | `edel_order` | `GET /v2/orders/{orderId}` | `read` | [rest-reference](https://docs.edel.finance/developers/rest-reference) |
| Edit an open Spot or Perps order in place (CCXT shape) | `edel_edit_order` | `POST /v2/spot/orders/{orderId}/edit`, `POST /v2/perps/orders/{orderId}/edit` | `trade` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Edit a batch of open Spot or Perps orders (CCXT shape) | `edel_edit_orders` | `POST /v2/spot/orders/edit`, `POST /v2/perps/orders/edit` | `trade` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Replace an open limit order in place | `edel_replace_order` | `POST /v2/spot/orders/{orderId}/edit`, `POST /v2/perps/orders/{orderId}/edit` | `trade` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Cancel a Spot or Perps order (CCXT shape) | `edel_cancel_spot_order` | `POST /v2/spot/orders/{orderId}/cancel`, `POST /v2/perps/orders/{orderId}/cancel` | `trade` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Cancel an order | `edel_cancel_order` | `POST /v2/orders/{orderId}/cancel` | `trade` | [rest-reference](https://docs.edel.finance/developers/rest-reference) |
| Cancel a batch | `edel_cancel_order_batch` | `POST /v2/orders/cancel` | `trade` | [rest-reference](https://docs.edel.finance/developers/rest-reference) |
| Cancel every open order of one market (CCXT shape) | `edel_cancel_all_orders` | `POST /v2/spot/orders/cancel-all`, `POST /v2/perps/orders/cancel-all` | `trade` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Fetch open Spot or Perps orders (CCXT shape) | `edel_fetch_open_orders` | `GET /v2/spot/accounts/{accountId}/orders/open`, `GET /v2/perps/accounts/{accountId}/orders/open` | `read` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Open orders | `edel_orders` | `GET /v2/accounts/{accountId}/orders/open` | `read` | [rest-reference](https://docs.edel.finance/developers/rest-reference) |
| Open Perps positions | `edel_positions` | `GET /v2/accounts/{accountId}/positions` | `read` | [rest-reference](https://docs.edel.finance/developers/rest-reference) |
| Close a Perps position | `edel_close_position` | `GET /v2/accounts/{accountId}/positions`, `POST /v2/order` | `trade` | [for-agents](https://docs.edel.finance/developers/accounts/for-agents) |
| Fetch Spot or Perps order history (CCXT shape) | `edel_fetch_orders` | `GET /v2/spot/accounts/{accountId}/orders`, `GET /v2/perps/accounts/{accountId}/orders` | `read` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Order history | `edel_order_history` | `GET /v2/accounts/{accountId}/orders` | `read` | [rest-reference](https://docs.edel.finance/developers/rest-reference) |
| Fetch Spot or Perps fills (CCXT shape) | `edel_fetch_my_trades` | `GET /v2/spot/accounts/{accountId}/fills`, `GET /v2/perps/accounts/{accountId}/fills` | `read` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Fill history | `edel_trade_history` | `GET /v2/accounts/{accountId}/fills` | `read` | [rest-reference](https://docs.edel.finance/developers/rest-reference) |
| Position history | `edel_position_history` | `GET /v2/accounts/{accountId}/positions/history` | `read` | [rest-reference](https://docs.edel.finance/developers/rest-reference) |
| Funding paid per position | `edel_funding` | `GET /v2/accounts/{accountId}/positions/history` | `read` | [rest-reference](https://docs.edel.finance/developers/rest-reference) |

From [for-agents](https://docs.edel.finance/developers/accounts/for-agents):

> Take profit and stop loss travel as `autoClose` (`takeProfitPriceAtoms`, `stopLossPriceAtoms`)
> on `edel_place_order` and on each `edel_place_order_batch` entry.

> `fundingPaidAtoms` is cumulative funding paid per episode. It is not per-payment funding
> history; the API does not serve that ledger, and this tool never invents payment rows.

## Deposits, withdrawals and listing requests

A key with the opt-in `funding` scope starts, reads and advances funding flows. It never signs.
When the owner must sign, the answer is `owner_signature_required` and the owner signs in the
browser. Each money action needs separate owner permission.

| Capability | MCP tool | REST route | Scope | Docs |
| --- | --- | --- | --- | --- |
| Test funds (Development only) | `edel_faucet_grant` | `POST /v2/accounts/{accountId}/faucet-grant` | `funding` | [for-agents](https://docs.edel.finance/developers/accounts/for-agents) |
| Funding intents | `edel_funding_intents` | `GET /v2/accounts/{accountId}/local-signing-funding-intents` | `funding` | same |
| xReserve deposit inputs (USDC bridged to USDCx) | `edel_xreserve_deposit` | `GET /v2/accounts/{accountId}/xreserve-deposit` | see the route | same |
| Start a deposit | `edel_deposit` | `POST /v2/accounts/{accountId}/deposits` | `funding` | same |
| Advance a deposit | `edel_deposit_confirm` | `POST /v2/accounts/{accountId}/deposits/confirm` | `funding` | same |
| Request a withdrawal | `edel_withdraw` | `GET /v2/accounts/{accountId}/party`, `POST /v2/withdrawals` | `funding` | same |
| Read a withdrawal | `edel_withdrawal` | `GET /v2/withdrawals/{withdrawalId}` | `funding` | same |
| Advance a withdrawal | `edel_withdrawal_confirm` | `POST /v2/withdrawals/{withdrawalId}/confirm` | `funding` | same |
| Settle a withdrawal | `edel_withdrawal_settle` | `GET /v2/withdrawals/{withdrawalId}`, `POST /v2/withdrawals/{withdrawalId}/authorize` | `funding` | same |
| Transfer history | `edel_transfers` | `GET /v2/accounts/{accountId}/transfers` | `funding` | same |
| Deposit route admission of the account (CCXT shape) | `edel_deposit_capabilities` | `GET /v2/accounts/{accountId}/deposit-capabilities` | `funding` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Cross-chain swap quote for a deposit or a withdrawal | `edel_squid_quote` | `POST /v2/accounts/{accountId}/squid-quote` | `funding` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Send a completed withdrawal on to another Canton Party the owner names | `edel_withdrawal_party_transfer` | `POST /v2/withdrawals/{withdrawalId}/party-transfer` | `funding` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Completed treasury credits with their payout reason | `edel_treasury_credits` | `GET /v2/accounts/{accountId}/treasury-credits` | `funding` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Pending fee-share payout offers | `edel_fee_share_offers` | `GET /v2/accounts/{accountId}/fee-share-offers` | `funding` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Read or start the acceptance of a fee-share offer | `edel_fee_share_accept` | `POST /v2/accounts/{accountId}/fee-share-offers/{offerId}/accept` | `funding` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Create a market listing request | `edel_create_listing_request` | `POST /v2/accounts/{accountId}/listing-requests` | `trade` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| List the account's market listing requests | `edel_listing_requests` | `GET /v2/accounts/{accountId}/listing-requests` | `read` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Read deposit status for a listing request | `edel_listing_request_deposit` | `GET /v2/accounts/{accountId}/listing-requests/{requestId}/deposit` | `read` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Confirm deposit for a listing request | `edel_listing_request_deposit_confirm` | `POST /v2/accounts/{accountId}/listing-requests/{requestId}/deposit/confirm` | `funding` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |

Which deposit path a venue offers is in its live contract and in
[for-humans](https://docs.edel.finance/developers/accounts/for-humans):

- Development: test funds with `edel_faucet_grant`.
- Where the collateral is USDCx: `edel_deposit` moves an exact amount of the USDCx the owner's
  Party already holds, then `edel_deposit_confirm` advances it. The owner signs once.
- USDC from Ethereum through Circle's xReserve bridge: `edel_xreserve_deposit` returns where the
  Party stands with the bridge and, once the bridge agreement exists, the deposit inputs for that
  venue. The USDC becomes USDCx only after the owner signs the mint
  (`POST /v2/accounts/{accountId}/xreserve-deposit/mint`) in the browser. A key never reaches it.

## Strategy agents

From the `agents` scope row of [for-agents](https://docs.edel.finance/developers/accounts/for-agents#what-a-key-can-do):

> Opt-in, never requested by default, and only a key the owner approved with a passkey through
> agent connect may hold it; a bot key cannot. [...] deploy it in paper or live mode [...] Paper
> agents simulate fills without placing orders or moving funds. Live agents trade from their own
> bound agent account, never the owner account, and only where the venue enables live agents;
> elsewhere a live deployment answers 400 `invalid_request`. Funding requires the separate
> `funding` scope and any required owner signature in the browser. Available on TestNet and
> Development only.

Quote the current row before you deploy. Do not restate it from this file.

Read each route description in the live OpenAPI document for its limits and the venues that
offer it.

| Capability | MCP tool | REST route | Scope | Docs |
| --- | --- | --- | --- | --- |
| Strategy catalogue | `edel_agent_strategies` | `GET /v2/agents/strategies` | none | [rest-reference](https://docs.edel.finance/developers/rest-reference) |
| Historical money estimate per strategy | `edel_agent_money_estimates` | `GET /v2/agents/strategy-estimates` | none | same |
| Net profit or required deposit for one strategy and market | `edel_agent_estimate_scenario` | `POST /v2/agents/strategy-estimate-scenarios` | none | same |
| Models an agent can use, with their cost | `edel_agent_models` | `GET /v2/agents/models` | none | same |
| What auto market selection uses | `edel_agent_market_selection` | `GET /v2/agents/market-selection` | none | same |
| Draft Pine from plain English | `edel_agent_pine` | `POST /v2/accounts/{accountId}/agents/pine` | `agents` | same |
| Backtest with a probability estimate | `edel_agent_backtest` | `POST /v2/accounts/{accountId}/agents/backtest` | `agents` | same |
| Deploy a paper or live agent | `edel_agent_deploy` | `POST /v2/accounts/{accountId}/agents` | `agents` | same |
| List agents | `edel_agents` | `GET /v2/accounts/{accountId}/agents` | `agents` | same |
| Pause, resume, start, delete | `edel_agent_command` | `POST /v2/accounts/{accountId}/agents/{deploymentId}/pause`, `POST /v2/accounts/{accountId}/agents/{deploymentId}/resume`, `POST /v2/accounts/{accountId}/agents/{deploymentId}/activate`, `DELETE /v2/accounts/{accountId}/agents/{deploymentId}` | `agents` | same |
| Choose the model | `edel_agent_model` | `PUT /v2/accounts/{accountId}/agents/{deploymentId}/model` | `agents` | same |
| Rename an agent | `edel_agent_rename` | `PUT /v2/accounts/{accountId}/agents/{deploymentId}/name` | `agents` | same |
| Send a message to an agent | `edel_agent_chat` | `POST /v2/accounts/{accountId}/agents/{deploymentId}/chat` | `agents` | same |
| List preset questions for agent chat | `edel_agent_chat_presets` | `GET /v2/agents/chat-presets` | none | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Read an agent's chat messages | `edel_agent_chat_messages` | `GET /v2/accounts/{accountId}/agents/{deploymentId}/chat` | `agents` | same |
| Close all positions of an owned, paused or stopped live agent with reduce-only market orders, with owner approval | `edel_agent_close` | `POST /v2/accounts/{accountId}/agents/{deploymentId}/close-position` | `agents` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Read the recorded decision behind an owned live agent's fill | `edel_agent_fill_decision` | `GET /v2/accounts/{accountId}/agents/{deploymentId}/fills/{tradeId}/decision` | `agents` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Read an owned agent's deployed Pine v5 code and strategy version | `edel_agent_strategy` | `GET /v2/accounts/{accountId}/agents/{deploymentId}/strategy` | `agents` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Action log and PnL | `edel_agent_actions` | `GET /v2/accounts/{accountId}/agents/{deploymentId}/actions` | `agents` | same |
| An agent account's wallet (owner live view) | `edel_agent_wallet` | `GET /v2/accounts/{accountId}/agents/{deploymentId}/wallet` | `agents` | same |
| An agent account's positions (owner live view) | `edel_agent_positions` | `GET /v2/accounts/{accountId}/agents/{deploymentId}/positions` | `agents` | same |
| An agent account's orders (owner live view) | `edel_agent_orders` | `GET /v2/accounts/{accountId}/agents/{deploymentId}/orders` | `agents` | same |
| An agent account's fills (owner live view) | `edel_agent_fills` | `GET /v2/accounts/{accountId}/agents/{deploymentId}/fills` | `agents` | same |
| An agent's protective skills | `edel_agent_skills` | `GET /v2/accounts/{accountId}/agents/{deploymentId}/skills` | `agents` | same |
| An agent's model fees | `edel_agent_fees` | `GET /v2/accounts/{accountId}/agents/{deploymentId}/fees` | `agents` | same |
| An agent account's lifetime trading performance | `edel_agent_performance` | `GET /v2/accounts/{accountId}/agents/{deploymentId}/performance` | `agents` | [mcp/tools](https://docs.edel.finance/developers/mcp/tools) |
| Fund your own agent account with test collateral | `edel_agent_fund` | `POST /v2/accounts/{accountId}/agent-accounts/{agentAccountId}/test-funding` | `funding` | same |
| Prepare funding of your own agent account | `edel_agent_fund_prepare` | `POST /v2/accounts/{accountId}/agent-accounts/{agentAccountId}/fundings` | `funding` | same |
| Confirm a prepared agent funding | `edel_agent_fund_confirm` | `POST /v2/accounts/{accountId}/agent-accounts/{agentAccountId}/fundings/{transferId}/confirm` | `funding` | same |
| Return funds from an agent account to your account | `edel_agent_withdraw` | `POST /v2/accounts/{accountId}/agent-accounts/{agentAccountId}/returns` | `funding` | same |

The model list comes only from `GET /v2/agents/models` of the venue. A removed model is not in
the list. Never hard code a model id.

The backtest route labels its probability "historical estimate, not a guarantee". Say so when
you report it. The money estimate is a cached historical dollar range, not a forecast; it says
when a strategy has too little history for a number. Report that case, do not invent one.

A deployment runs on one to three listed markets: send `marketSelection` with explicit
`marketIds`, or `auto` to let the named model pick and record its reason. The owner watches
deployments live on the `account.agents` realtime channel.

## Organizations and partners (REST `/v2`)

Partner organizations authenticate with an organization API key (`GET /v2/organization-key`) to
manage sub-accounts, internal transfers, mother balances, listing requests and market analytics.
Read each route description in the live `GET <REST origin>/openapi.json` for required headers and
scopes.

- Organization key and profile: `GET /v2/organization-key`, `GET /v2/organizations/{organizationId}`,
  `GET /v2/organizations/{organizationId}/members`
- Sub-accounts and transfers: `GET /v2/organizations/{organizationId}/sub-accounts`,
  `POST /v2/organizations/{organizationId}/sub-accounts`,
  `GET /v2/organizations/{organizationId}/transfers`,
  `POST /v2/organizations/{organizationId}/transfers`,
  `GET /v2/organizations/{organizationId}/mother-balance`,
  `GET /v2/organizations/{organizationId}/deposits`,
  `GET /v2/organizations/{organizationId}/funding`
- Listing requests and analytics: `GET /v2/organizations/{organizationId}/listing-requests`,
  `POST /v2/organizations/{organizationId}/listing-requests`,
  `GET /v2/organizations/{organizationId}/market-analytics`

## Additional `/v2` REST routes

These CCXT `/v2` routes are also served directly over REST (check the live `GET /openapi.json` for
product-scoped `/v2/spot/...` and `/v2/perps/...` paths):

- `GET /v2/funding-rates`, `GET /v2/perps/funding-rates`, `GET /v2/trading-fees`
- `GET /v2/perps/accounts/{accountId}/positions`
- `POST /v2/spot/orders`, `POST /v2/perps/orders`, `POST /v2/spot/orders/cancel`,
  `POST /v2/perps/orders/cancel`, `POST /v2/orders/cancel-all`, `POST /v2/twap-orders`

## Owner only (no tool, no key)

The MCP exclusions table of [for-agents](https://docs.edel.finance/developers/accounts/for-agents) gives the reason for each route. Two rows
cover these:

> The flow needs the owner's passkey, social sign-in or local signing ceremony in a browser,
> which an agent cannot perform.

> The API refuses every API key on this route with 403 passkey_required; widening the key
> allowlist is an owner security decision.

The routes in those rows include login and registration, Party binding
(`POST /v2/accounts/{accountId}/party` and its `complete` and `consent` routes), agent approval,
API key listing and revocation, adding a passkey (`POST /v2/accounts/{accountId}/passkeys`),
the xReserve mint, affiliate earnings and profile, and favorites. Do not try to reach them with a
key.

## Realtime tickets

`POST /v2/realtime/ticket`, `PUT /v2/realtime/ticket` and `DELETE /v2/realtime/ticket` mint,
rotate and revoke the WebSocket ticket. MCP cannot carry a ticket. The
[realtime reference](https://docs.edel.finance/developers/realtime-reference) and the venue's
AsyncAPI document own each channel, its payload and its authentication.

## WebSocket channels

This is an index of the public channel groups, not a contract. The
[realtime reference](https://docs.edel.finance/developers/realtime-reference) lists every channel
with its own page, for example
[account.margin](https://docs.edel.finance/developers/realtime/account-margin). Read the page
before you subscribe.

| Group | What it streams | Authentication |
| --- | --- | --- |
| `market.*` | Public data of one market | none |
| `markets.prices` | Prices of all markets in one stream | none |
| `system.status` | The venue state | none |
| `account.*` | The owner's orders, fills, positions, margin, balances, funding and agents | realtime ticket |

Two fields that a client must not miss, quoted from the AsyncAPI field descriptions:

- `initialMarginAtoms` on [account.margin](https://docs.edel.finance/developers/realtime/account-margin):
  "Account-wide initial margin in settlement-asset atoms [...] Absent from legacy producers."
- The stored order attributes on
  [account.orders](https://docs.edel.finance/developers/realtime/account-orders): `orderType`,
  `postOnly` and `reduceOnly` are "Present on every order lifecycle frame when stored", and
  `timeInForce` is the "Accepted stored time in force on placement, cancellation, replacement and
  fill-state updates".
