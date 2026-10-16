# edel-ai-config

Agent skills and MCP configuration for the Edel PERPS public API. Install them into your coding
agent, then let the agent read the Edel developer docs and trade only after you say so.

## Install the skill only

```sh
npx skills add Edel-Finance/edel-ai-config
```

This adds one skill, `edel-backend`, to your agent. The skill reads
`skills/edel-backend/AUTH.md` before any private call.

## Install the Claude Code plugin

The `edel` plugin carries the same skill plus the public Edel MCP servers, one per environment.
It authenticates with your own API key only. It never uses another person's browser session.

| Server | Environment | URL |
| --- | --- | --- |
| `edel-development` | Development | `https://mcp-dev.edel-api.xyz/mcp` |
| `edel-testnet` | TestNet | `https://mcp-testnet.edel-api.xyz/mcp` |
| `edel-production` | Production | Disabled. No public MCP yet. Shows as `Not configured`. |

1. Add the marketplace and install the plugin:

   ```sh
   claude plugin marketplace add Edel-Finance/edel-ai-config
   claude plugin install edel@edel-ai-config
   ```

2. Get your own key for each environment you use. Run the helper from a clone of this
   repository. It prints a page and a code. You open
   the page in your own browser, sign in with your passkey, check the code and approve. The
   helper saves the key in the plugin option, which Claude Code keeps in the OS secure credential
   store:

   ```sh
   scripts/connect.sh development claude
   scripts/connect.sh testnet claude
   ```

   Or set the key yourself with `/plugin`, then Installed, `edel`, Configure options. Do not use
   `--config KEY=VALUE`: it puts the key on the command line.

3. Restart Claude Code. Run `claude mcp list`. Each environment with a key shows as connected.
   An environment without a key shows a `401` with `apiKeyRejection: malformed`.

4. In a session, call `edel_connect` to confirm the key, then `edel_status`. Trading needs the
   AUTH.md order and your explicit permission for each order.

A key expires (24 hours by default, 7 days at most). Run step 2 again when the server answers
`401` with `nextTool: edel_connect`.

## Other MCP clients

[mcp/README.md](mcp/README.md) has a generic config, `mcp/servers.json`, that reads the key from
an environment variable or the macOS Keychain. It also has the smoke test:

```sh
scripts/smoke.sh development testnet
```

`scripts/check.sh` tests both scripts offline with a fake `curl`. It needs no key and no network.

## Onboarding for direct API use

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

- Developer docs: <https://docs.edel.finance/developers/overview> (live; one site for every venue).
- MCP and API keys: <https://docs.edel.finance/developers/accounts/for-agents>.
- REST contract: `GET https://api.edel-api.xyz/openapi.json` (production; not live yet).
- This repo carries no SDK, MCP server, dependencies or copied contracts. See
  [AGENTS.md](AGENTS.md).

License: not selected yet.
