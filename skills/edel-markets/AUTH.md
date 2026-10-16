# Edel PERPS authentication and secure setup prerequisite

Do these steps in order. Every private route and account channel needs a verified DFNS end user.
Trading also needs an `active` Canton Party binding. Steps marked **human** need a person in a
browser with a passkey; an agent must stop and ask at each one.

Two things are easy to confuse:

- **Signing identity (the wallet side).** A DFNS end-user credential (passkey) plus a delegated
  signing key. Registration creates both. Login proves the credential and returns a bearer.
- **Canton Party binding.** The on-ledger identity bound to the Edel account through secure setup,
  signed with that key. Reads need only the bearer. Trading needs the binding to be `active`.

Public routes and values below come from the generated Edel OpenAPI document. The live document
at `GET /openapi.json` wins when they disagree.

## Output and secret rules

- Hold the bearer, tickets, challenges and Party identifiers in process memory only. Never place
  them on a command line, in a file, in chat, in logs or in git.
- Report only allowlisted output: HTTP status, booleans, the error `code`, `retryable`,
  `recoveryActions` and `requestId`. Never echo a raw response or a raw provider error.
- The examples below are pseudocode for an in-memory authenticated fetch. They are not scripts.
  Do not add a dependency or a helper script to run them.

## Origins

Use the origins of one venue for REST, WebSocket and MCP. Never mix venues, and never switch
venue on your own; ask the owner. The docs page
<https://docs.edel.finance/developers/introduction> ("Base URLs") is the source. When it and
this table disagree, the docs page wins.

| Venue | REST (and `/openapi.json`) | WebSocket | MCP |
| --- | --- | --- | --- |
| Testnet | `https://testnet.edel-api.xyz` | `wss://realtime-testnet.edel-api.xyz/streams/v1/ws` | `https://mcp-testnet.edel-api.xyz/mcp` |
| Development | `https://dev.edel-api.xyz` | `wss://realtime-dev.edel-api.xyz/streams/v1/ws` | `https://mcp-dev.edel-api.xyz/mcp` |
| Mainnet | Not published. | Not published. | Not published. |

The docs say an MCP endpoint must be provisioned and verified by the venue's rollout. If an
origin does not answer, report it. Do not guess another host.

## Step 0: read capabilities (no auth)

This route is public and returns no secret, so a plain request is safe:

```sh
curl --fail-with-body --silent "https://testnet.edel-api.xyz/v1/auth/capabilities"
```

The response is `external-auth-capabilities/v1`. The field table in the
[introduction](https://docs.edel.finance/developers/introduction) is the source; quoted here:

> | Field | Values | What your client does |
> | --- | --- | --- |
> | `passkeyLogin` | `available` or `dfns_not_configured` | Offer passkey login only when `available`. |
> | `socialRegistrationProviders` | A list such as `["google"]`, or `[]` | Offer registration only through a listed provider. An empty list means registration is closed. |
> | `socialLoginProviders` | A list such as `["google"]`, or `[]` | Offer social login only through a listed provider. |
> | `delegatedRegistration` | `product_identity_required` or `dfns_not_configured` | Username or email registration is not offered. |
> | `emailOtp` | Always `email_otp_provider_required` | Email one-time codes are not offered. |
> | `credentialRecovery` | Always `credential_recovery_not_configured` | Lost-passkey recovery is not offered. |

Read this at the start of every session. Composition can change. Steps 1 and 2 cover the human
session: a DFNS end-user bearer. An agent uses an owner-approved API key instead (step 2b). There
are no personal access tokens in the public API.

## Step 1: create or reuse the signing identity

**Reuse.** If the owner already has an Edel identity, skip to step 2. Ask for the registered
username; do not register again.

**Create (human).** Only when `socialRegistrationProviders` lists a provider (today only `google`):

1. Generate one opaque `Idempotency-Key` and keep it for the whole attempt. This route requires it.
2. `POST /v1/auth/social/register` with header `Idempotency-Key` and body `{"idToken": "<Google
   OIDC ID token>"}`. The response is `external-auth-register-init/v1` with a WebAuthn creation
   challenge and a `temporaryAuthenticationToken`.
3. **Human:** the browser runs `navigator.credentials.create()` with that challenge.
4. `POST /v1/auth/register/complete` with the `temporaryAuthenticationToken`, the `Fido2`
   credential result, and a fresh Google token for the same subject. Success is
   `external-auth-register-complete/v1`.

Registration creates the DFNS end-user credential, the delegated signing key and the Edel account
mapping. It does not create a Canton Party binding. The `walletState` field in this response is
legacy and proves nothing about the binding.

If a registration result is ambiguous, do not repeat it. `POST /v1/auth/social/register/recover`
with the same `Idempotency-Key` and a fresh Google token resolves it.

## Step 2: authenticate (human)

Passkey login, when `passkeyLogin` is `available`:

1. `POST /v1/auth/login/init` with `{"username": "<registered DFNS username>"}`. The response is
   `external-auth-login-init/v1` with `challenge`, `challengeIdentifier` and `allowCredentials`.
2. **Human:** the browser runs `navigator.credentials.get()` with that challenge.
3. `POST /v1/auth/login/complete` with `challengeIdentifier` and a `firstFactor` of kind `Fido2`
   carrying the assertion.

Google login, when `socialLoginProviders` lists `google`: `POST /v1/auth/social/login` with
`{"idToken": "<Google OIDC ID token>"}`.

Both return `external-auth-login/v1` with `token`. That token is the DFNS end-user bearer. Send it
as `Authorization: Bearer <token>` on private REST routes only. Ignore `walletState` here too.

```text
// pseudocode, in memory only
session.bearer = loginComplete.token        // never printed, never on argv
report({ status: 200, authenticated: true })
```

## Step 2b: connect an agent with an API key (human approves)

Source: <https://docs.edel.finance/developers/accounts/for-agents> ("Connect with an API key").

1. `POST /v1/agent-connect/start` with `clientName` and the smallest `scopes` the task needs.
   `agents` and `funding` are opt-in; ask for them only when the owner wants them.
2. Show the owner `verificationUrl` and `userCode`. **Human:** the owner approves with a passkey.
3. Poll `POST /v1/agent-connect/complete` with `connectCode` every `intervalSeconds`, as the
   docs page says. It returns `apiKey` exactly once.
4. Send `Authorization: Bearer <apiKey>`. Keep the key in a file only you can read. For MCP, put
   the same header on every request.

`GET /v1/api-keys/current` confirms the key's scopes and expiry. A key never signs, never changes
the Party binding and never approves another agent. Only the owner lists or revokes keys.

## Passkeys belong to one venue

Each venue has its own passkey relying party. A passkey made on Testnet never signs on
Development, and one made on a retired address signs nowhere. Read them with `edel_passkeys` (or
`GET /v1/accounts/{accountId}/passkeys`): each has a `status` of `usable_here`,
`other_relying_party` or `inactive`. `edel_me` (`GET /v1/me`) returns the same list inside the
owner's whole profile; a section it cannot read is null and named in `unavailable`.

- No `usable_here` passkey: the owner cannot sign in or approve anything in this venue, and no
  passkey can approve a new one. Tell the owner to contact support. Do not retry login.
- Adding, naming and removing a passkey is the owner's, in the browser (Settings, Profile). A key
  never reaches those routes. There is no rename and no last-used time.

## Step 3: learn the account id

```text
// pseudocode, in memory only
res = fetch(origin + "/v1/realtime/ticket", { method: "POST",
        headers: { Authorization: "Bearer " + session.bearer } })
session.accountId = res.body.accountId     // keep; never guess an account id
session.ticket    = res.body.ticket        // WebSocket only; expires at res.body.expiresAt
report({ status: res.status, accountIdKnown: session.accountId != null })
```

Rotate the ticket with `PUT /v1/realtime/ticket` and revoke the family with
`DELETE /v1/realtime/ticket`. Neither takes the bearer; the ticket is the credential.

## Step 4: read-only sanity check

Reads need the bearer only. They do not need the Party binding.

```text
// pseudocode, in memory only
markets  = fetch(origin + "/v1/markets")                                   // public
account  = fetch(origin + "/v1/accounts/" + session.accountId, auth)       // bearer header
open     = fetch(origin + "/v1/accounts/" + session.accountId + "/orders/open", auth)
report({ markets: markets.status, account: account.status, openOrders: open.status,
         marketCount: markets.body.markets.length, openOrderCount: open.body.orders.length })
```

Summarize balances, margin and equity for the owner in words. Stop here unless the owner asks
for more.

## Step 5: verify or complete the Canton Party binding (before trading)

Check first:

```text
// pseudocode, in memory only
party = fetch(origin + "/v1/accounts/" + session.accountId + "/party", auth)
report({ status: party.status, partyStatus: party.body.status })   // never the partyId
```

The response is `dfns-party-onboarding/v1` with `status` in `not_started`, `generated`, `signing`,
`submitted`, `active` or `failed`.

- `active`: the binding exists. Reuse it. Do not call the init route. Go to step 6.
- `submitted`: the venue is still reconciling. Read the status again later. Do not init again.
- `not_started`, `generated`, `signing` or `failed`: run the secure setup below.

**Secure setup (human).** Login alone does not authorize this write. Each challenge is a DFNS
User Action that the owner approves with the passkey.

1. `POST /v1/accounts/{accountId}/party` with the bearer. The venue resolves the owner's delegated
   signing key and returns one or more passkey challenges. Development returns three. An already
   active account returns its binding with no new challenges. No `Idempotency-Key` is needed.
2. **Human:** approve every challenge in the browser, in order.
3. `POST /v1/accounts/{accountId}/party/complete` with the signed proofs.
4. `GET /v1/accounts/{accountId}/party` again. Continue only when `status` is `active`.

There is no Party selector and no caller-supplied Party id. There is no route that binds a Party
before login; the binding requires the bearer from step 2.

## Step 6: explicit permission before any money action

Only after steps 0 to 5 pass, and only on an explicit owner instruction naming the action:

1. `POST /v1/orders/preview` with the intended order. It reserves nothing and needs no
   `Idempotency-Key`.
2. Show the preview. Wait for a "yes".
3. `POST /v1/orders` with a fresh `Idempotency-Key` header. Send that header on every route
   where the live contract marks it required. Required body fields: `accountId`, `marketId`, `clientOrderId`, `side`, `orderType`,
   and `quantity` or `notional`; a limit order also needs `price`. The response is accepted for
   asynchronous processing; watch `account.orders` on the WebSocket for the outcome.

Deposits and withdrawals are owner-signed DFNS actions and need separate explicit permission. See
the funding section of [CAPABILITIES.md](CAPABILITIES.md).

## Limits and errors

Read the current limits in the docs ("Rate limits and back-pressure" in
<https://docs.edel.finance/developers/introduction>) and in each route description. At the time
of writing the docs say: public auth is limited to 20 requests per 60 seconds per trusted client
IP, and a venue allows 600 authenticated requests per 60 seconds by default.
- Failures use `external-rest-error/v1`: `code`, `safeMessage`, `retryable`, `recoveryActions`,
  `requestId`. Report `code`, `retryable`, `recoveryActions` and `requestId` only.

| HTTP | Classify as | Then |
| --- | --- | --- |
| `401` | Authentication rejected. | Read `code`. Stop. Ask the human to log in again. Do not retry the same bearer. Do not guess why. |
| `403` | Forbidden for this bearer and resource. | Read `code`. Stop. Do not substitute another account id and do not retry. Report `requestId`. |
| `429` | `rate_limited`. | Wait for `retry_after`. |
| `503` | `service_degraded`. | Follow `recoveryActions`. Never replay registration or a key write. |
| other | Read `code` and `retryable`. | A non-retryable code never succeeds on retry. |

## Not available today

- Username or email registration, email one-time codes, lost-passkey recovery.
- Long-lived tokens for a human session. A session uses the DFNS end-user bearer and short-lived
  realtime tickets. API keys are for agents and market makers, and they expire.
- Any unattended passkey or User Action completion.
