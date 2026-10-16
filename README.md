# edel-ai-config

Agent skills for the Edel PERPS public API. Install them into your coding agent, then let the
agent read the Edel developer docs and trade only after you say so.

## Install

```sh
npx skills add Edel-Finance/edel-ai-config
```

This adds one skill, `edel-markets`, to your agent. It covers every public Edel PERPS capability:
REST, CCXT `/v2`, WebSockets, MCP tools, paper strategy agents, deposits and withdrawals. The skill
reads `skills/edel-markets/AUTH.md` before any private call and finds each capability in
`skills/edel-markets/CAPABILITIES.md`.

## Onboarding

Do these steps in order. Steps 2 and 4 need a human with a browser and a passkey. An agent cannot
complete them alone.

1. Install the skill with the command above.
2. Read [skills/edel-markets/AUTH.md](skills/edel-markets/AUTH.md). Create or reuse your signing
   identity (passkey plus delegated signing key), then log in. Login returns a bearer token. The
   agent keeps it in memory and never prints it.
3. Let the agent run the read-only sanity check in AUTH.md: capabilities, account id, markets,
   account snapshot. Reads need only the bearer.
4. Before any trade, the agent checks your Canton Party binding. If it is already `active`, it is
   reused. If not, you approve each passkey prompt yourself to complete secure setup.
5. Give the agent explicit permission for each order. The skill refuses to place, cancel, deposit
   or withdraw without it.

## Where the facts live

The docs are the source of truth. The skill points at them and quotes them; it does not restate
facts from memory.

- Developer docs: <https://docs.edel.finance/developers/overview> (live; one site for every venue).
- REST contract: `GET <REST origin>/openapi.json` of the venue you use. The origins per venue are
  in `skills/edel-markets/AUTH.md`.
- CI: `.github/workflows/contract-names.yml` fails when the skill names an MCP tool or a REST
  route that the published contract does not have.
- This repo carries no SDK, CLI, MCP server, dependencies or copied contracts. See
  [AGENTS.md](AGENTS.md).

License: not selected yet.
