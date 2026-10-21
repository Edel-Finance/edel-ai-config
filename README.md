# edel-ai-config

Agent skills and MCP configuration for the Edel PERPS public API. Install them into your coding
agent, then let the agent read the Edel developer docs and trade only after you say so.

## Public MCP servers

Every plugin package in this repository carries the `edel-markets` skill plus the public Edel MCP
endpoints, authenticated with your own API key only. Never use another person's browser session.

| Server | Environment | URL | Environment variable |
| --- | --- | --- | --- |
| `edel-development` | Development | `https://mcp-dev.edel-api.xyz/mcp` | `EDEL_MCP_KEY_DEVELOPMENT` |
| `edel-testnet` | TestNet | `https://mcp-testnet.edel-api.xyz/mcp` | `EDEL_MCP_KEY_TESTNET` |
| `edel-production` | Production | Disabled placeholder (no public MCP yet) | none |

Approve a key in your browser and store it in the macOS login Keychain with `scripts/connect.sh`
(see [mcp/README.md](mcp/README.md)), then export `EDEL_MCP_KEY_TESTNET` or
`EDEL_MCP_KEY_DEVELOPMENT` in your shell profile before starting your agent client.

## Install by harness

### Claude Code

1. Add the marketplace and install the plugin:

   ```sh
   claude plugin marketplace add Edel-Finance/edel-ai-config
   claude plugin install edel@edel-ai-config
   ```

2. Approve your own key for each environment you use and store it in the OS secure credential
   store:

   ```sh
   scripts/connect.sh testnet claude
   scripts/connect.sh development claude
   ```

   Or set the key with `/plugin`, then Installed, `edel`, Configure options. Do not pass a key on
   the command line.

3. Restart Claude Code and run `claude mcp list` and `claude plugin list` to verify the servers
   and skill.

### Codex

1. Add the marketplace and install the plugin:

   ```sh
   codex plugin marketplace add Edel-Finance/edel-ai-config
   codex plugin add edel@edel-ai-config
   ```

2. Export `EDEL_MCP_KEY_TESTNET` (or `EDEL_MCP_KEY_DEVELOPMENT`) from your secret store before
   starting Codex.

3. Verify the installed plugin and MCP servers:

   ```sh
   codex plugin list
   codex mcp list
   ```

### Antigravity

1. Install the plugin from a clone of this repository (or point `agy plugin install` at the
   directory):

   ```sh
   agy plugin install .
   ```

2. Export `EDEL_MCP_KEY_TESTNET` (or `EDEL_MCP_KEY_DEVELOPMENT`) from your secret store before
   starting Antigravity.

3. Verify the installed plugin, skill and MCP servers:

   ```sh
   agy plugin list
   ```

### Grok

1. Install and enable the plugin:

   ```sh
   grok plugin install Edel-Finance/edel-ai-config --trust
   grok plugin enable edel
   ```

   Or install through the Grok marketplace commands:

   ```sh
   grok plugin marketplace add Edel-Finance/edel-ai-config
   grok plugin install edel --trust
   grok plugin enable edel
   ```

2. Export `EDEL_MCP_KEY_TESTNET` (or `EDEL_MCP_KEY_DEVELOPMENT`) from your secret store before
   starting Grok.

3. Verify the installed plugin and MCP servers:

   ```sh
   grok plugin list
   grok plugin details edel
   grok mcp doctor
   ```

### Hermes

1. Install the portable Agent Plugins v1 package:

   ```sh
   hermes plugins install Edel-Finance/edel-ai-config --enable
   ```

2. Add the TestNet MCP server. Hermes prompts for your key and saves it to its private secret
   store; the key never appears on the command line:

   ```sh
   hermes mcp add edel-testnet --url https://mcp-testnet.edel-api.xyz/mcp --auth header
   ```

   Use `edel-development` and `https://mcp-dev.edel-api.xyz/mcp` instead for Development.

3. Verify the installed skill and MCP server:

   ```sh
   hermes plugins list --no-bundled
   hermes plugins show edel
   hermes mcp list
   ```

### OpenClaw

Install the OpenClaw skill from `.openclaw/skills/edel-markets/SKILL.md`:

```sh
openclaw skills install git:Edel-Finance/edel-ai-config
```

Or copy `.openclaw/skills/edel-markets` into `~/.openclaw/skills/edel-markets`, then add the
MCP entries from [mcp/servers.json](mcp/servers.json) to your OpenClaw MCP configuration.

### Install the skill only (any Agent Skills client)

```sh
npx skills add Edel-Finance/edel-ai-config --skill edel-markets
```

This adds one skill, `edel-markets`, to your agent. It covers every public Edel PERPS capability:
REST, CCXT `/v2`, WebSockets, MCP tools, paper strategy agents, deposits and withdrawals. The skill
reads `skills/edel-markets/AUTH.md` before any private call and finds each capability in
`skills/edel-markets/CAPABILITIES.md`.

## Generic MCP config and smoke test

[mcp/README.md](mcp/README.md) has a generic config, `mcp/servers.json`, that reads the key from
an environment variable or the macOS Keychain. It also has the smoke test:

```sh
scripts/smoke.sh development testnet
```

`scripts/check.sh` tests both scripts offline with a fake `curl`. It needs no key and no network.

## Onboarding for direct API use

Do these steps in order. Steps 2 and 4 need a human with a browser and a passkey. An agent cannot
complete them alone.

1. Install the skill or plugin with the commands above.
2. Read [skills/edel-markets/AUTH.md](skills/edel-markets/AUTH.md). Create or reuse your signing
   identity (passkey plus delegated signing key), then log in. Login returns a bearer token. The
   agent keeps it in memory and never prints it.
3. Let the agent run the read-only sanity check in AUTH.md: capabilities, account id, markets,
   account snapshot. Reads need only the bearer.
4. Before any trade, the agent checks your Canton Party binding. If it is already `active`, it is
   reused. If not, you approve each passkey prompt yourself to complete secure setup.
5. Give the agent explicit permission for each order. The skill refuses to place, cancel, deposit
   or withdraw without it.

A key expires (24 hours by default, 7 days at most). Approve a fresh key when the server answers
`401` with `nextTool: edel_connect`.

## Where the facts live

The docs are the source of truth. The skill points at them and quotes them; it does not restate
facts from memory.

- Developer docs: <https://docs.edel.finance/developers/overview> (live; one site for every venue).
- MCP and API keys: <https://docs.edel.finance/developers/accounts/for-agents>.
- REST contract: `GET <REST origin>/openapi.json` of the venue you use. The origins per venue are
  in `skills/edel-markets/AUTH.md`.
- CI: `.github/workflows/contract-names.yml` fails when the skill names an MCP tool or a REST
  route that the published contract does not have.
- This repo carries no SDK, MCP server, dependencies or copied contracts. See
  [AGENTS.md](AGENTS.md).

License: not selected yet.
