# edel-ai-config

Agent skills for the Edel PERPS public API. Install them into your coding agent, then let the
agent read the Edel developer docs and trade only after you say so.

## Install

```sh
npx skills add Edel-Finance/edel-ai-config
```

This adds one skill, `edel-backend`, to your agent. The skill reads
`skills/edel-backend/AUTH.md` before any private call.

## Onboarding

Do these steps in order. Steps 2 and 4 need a human with a browser and a passkey. An agent cannot
complete them alone.

1. Install the skill with the command above.
2. Read [skills/edel-backend/AUTH.md](skills/edel-backend/AUTH.md). Create or reuse your signing
   identity (passkey plus delegated signing key), then log in. Login returns a bearer token. The
   agent keeps it in memory and never prints it.
3. Let the agent run the read-only sanity check in AUTH.md: capabilities, account id, markets,
   account snapshot. Reads need only the bearer.
4. Before any trade, the agent checks your Canton Party binding. If it is already `active`, it is
   reused. If not, you approve each passkey prompt yourself to complete secure setup.
5. Give the agent explicit permission for each order. The skill refuses to place, cancel, deposit
   or withdraw without it.

## Where the facts live

- Developer docs: <https://dev-docs.edel-api.xyz> (Development venue; production hosts are not
  published yet).
- REST contract: `GET https://dev.edel-api.xyz/openapi.json`.
- This repo carries no SDK, CLI, MCP server, dependencies or copied contracts. See
  [AGENTS.md](AGENTS.md).

License: not selected yet.
