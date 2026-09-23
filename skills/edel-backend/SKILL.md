---
name: edel-backend
description: "Trigger: Edel, Edel PERPS, edel-api, perpetuals, Canton perps, DFNS login, Edel order, Edel account. Use the Edel PERPS public API safely: authenticate first, verify the active Party binding, trade only with explicit owner permission."
metadata:
  author: "Edel-Finance"
  version: "1.0"
---

## Activation Contract

Use this skill when the task touches the Edel PERPS public API: markets, accounts, orders,
positions, realtime channels, or Edel login. Public trading bots are in scope. Admin, operator and
internal bot-control surfaces are not public and are out of scope.

## Hard Rules

- Read [AUTH.md](AUTH.md) before any private call. Follow its order: capabilities, signing
  identity, login, account id, reads, active Party binding, then permission per money action.
- The live contract is `GET <REST origin>/openapi.json` and <https://docs.edel-api.xyz>.
  Do not call a route that is not in that document.
- Never place, cancel, deposit or withdraw without an explicit owner instruction for that action.
  Preview an order with `POST /v1/orders/preview` and show the result first.
- A passkey prompt or DFNS User Action is a human step in a browser. Stop and ask; never fake it.
- Hold bearer, ticket, challenges and Party identifiers in memory only. Never on a command line,
  in a file or in output. Report only status, booleans, `code`, `retryable`, `requestId`.
- Send the bearer on REST only. WebSockets take a short-lived ticket from `POST /v1/realtime/ticket`.
- Use the `accountId` returned by ticket minting. Never guess or substitute an account id.
- `Idempotency-Key` is required where the contract says so: order placement, order cancellation,
  withdrawals, social registration. Reuse the same key when you retry the same intent.
- Money values cross the wire as atom strings. Never do float math on them.
- Stream state over WebSockets. Do not poll REST for data a channel already pushes.

## Decision Gates

| Situation | Action |
| --- | --- |
| No bearer yet | AUTH.md steps 0 to 2. Ask the human to complete the passkey. |
| Owner wants reads only | AUTH.md steps 3 and 4. No Party binding needed. |
| Party status is `active` | Reuse it. Do not call party init again. |
| Party status is not `active` and owner wants to trade | AUTH.md step 5. Human approves each challenge. |
| Capability reports unavailable | Say so. Do not look for another route. |
| `401` | Authentication rejected. Read `code`, stop, ask the human to log in again. |
| `403` | Forbidden. Read `code`, stop, report `requestId`. No account substitution, no retry. |
| `503 service_degraded` | Follow `recoveryActions`. Never replay registration or a key write. |
| Owner asks to trade | Confirm market, side, size, price and leverage. Preview. Then wait for a "yes". |

## Execution Steps

1. `GET /v1/auth/capabilities`. Record which login paths exist right now.
2. Complete AUTH.md steps 1 to 3 with the human: identity, login, account id.
3. Run the read-only check: `GET /v1/markets`, `GET /v1/accounts/{accountId}`.
4. Report the account snapshot and open orders to the owner in words.
5. Before any order: `GET /v1/accounts/{accountId}/party` must be `active`. If not, AUTH.md step 5.
6. Only on an explicit instruction: preview, then `POST /v1/orders` with a fresh `Idempotency-Key`
   and `clientOrderId`. Report `code`, `retryable` and `requestId` on any failure.

## Output Contract

Report: capabilities seen, identity reused or created, Party status, sanity-check statuses, and
the exact owner instruction that authorized each write. Include `requestId` for every failure.

## References

- [AUTH.md](AUTH.md): mandatory identity, login and Party binding order, with public routes.
- <https://docs.edel-api.xyz>: generated REST and WebSocket reference.
