# Agent rules for edel-ai-config

This repository distributes agent skills and MCP client configuration for the Edel PERPS public
API. Nothing else.

## Scope

- Keep it small: `README.md`, `AGENTS.md`, `.gitignore`, `skills/<name>/SKILL.md` with its local
  references, the plugin and skill manifests for Claude Code (`.claude-plugin/`), Codex
  (`.codex-plugin/`, `.agents/plugins/`, `skills/.codex-plugin/`), Grok (`.grok-plugin/`,
  `skills/plugin.json`, `skills/.mcp.json`), Antigravity (`plugin.json`, `mcp_config.json`),
  Hermes (`plugin.json`, `mcp.json`), Cursor (`.cursor-plugin/`), Gemini CLI
  (`gemini-extension.json`), Pi (the conventional `skills/` folder), ChatGPT (`chatgpt/`),
  OpenClaw (`.openclaw/skills/`), the shared `.mcp.json` and
  generic client config in `mcp/`, the shell helpers in `scripts/` (`connect.sh`, `smoke.sh`, and
  the offline `check.sh` that tests them), the `contract-names` CI check in `.github/`, and the
  hourly `sync-public-tools` workflow that regenerates `skills/edel-markets/TOOLS.md` from the same
  public sources. Install paths include `npx skills add Edel-Finance/edel-ai-config`,
  `claude plugin install edel@edel-ai-config`, `codex plugin add edel@edel-ai-config`,
  `agy plugin install`, `grok plugin install Edel-Finance/edel-ai-config --trust`, and
  `hermes plugins install Edel-Finance/edel-ai-config`.
- The docs are the source of truth. A skill points at the docs page or the live contract and
  quotes it. It never states a limit, scope, field or status from memory.
- The `contract-names` check reads only public sources and needs no secret. Never add a token.
- `sync-public-tools` reads the same public sources. Its only optional secret is `SYNC_PR_TOKEN`
  (pull requests write on this repository), because the organization does not let `GITHUB_TOKEN`
  open pull requests. It pushes only `automation/sync-public-tools`, never `main`. Never edit
  `TOOLS.md` by hand.
- No application code, SDK, MCP server, package manifest, lockfile or dependency. The helpers use
  only `bash`, `curl` and the OS credential tool.
- MCP configs point only at the public MCP URL of each environment, as published in the public
  docs. Production stays a disabled placeholder until its MCP is public.
- MCP auth uses the user's own API key from the OS secure store or an environment variable. Never a
  key in a repo file or on a command line, and never another person's browser session.
- No copied OpenAPI, AsyncAPI, Postman or realtime contract files. Link to the live docs and the
  live `GET /openapi.json` instead. Copies drift.
  One exception: `chatgpt/actions.openapi.json` is a small read-only subset for a custom GPT,
  because a GPT needs only the public reads. `contract-names` fails when it drifts.
- Public API only. Document the routes and channels in the public OpenAPI and AsyncAPI documents,
  including their use by public trading bots. Do not document Admin, operator or internal
  bot-control surfaces, internal service hostnames, environment variables, provider request
  bodies or private runbooks.
- Verified public origins (the REST, WebSocket and docs hosts in the public docs) are not secrets
  and may be written down.

## Safety

- No secrets, tokens, tickets, passkeys, private keys, connection strings or Party identifiers,
  in any file, example, commit or log. Examples hold credentials in memory only and print only
  status, booleans, `code`, `retryable` and `requestId`. Never put a credential on a command line.
- Authentication comes first. Every skill must require the AUTH.md order: capabilities, signing
  identity, login, account id, reads, then an `active` Canton Party binding before any trade,
  then explicit owner permission per money action.
- A Canton Party binding is not the signing identity. Registration creates the passkey and the
  delegated signing key; secure setup binds the Party. Say which one you mean.
- Never describe a passkey or DFNS User Action as something an agent completes unattended. A human
  approves each one in a browser.
- On `401` or `403`, classify (authentication rejected, forbidden), read the documented `code`,
  and stop. No blind retry and no invented diagnosis.
- Never invent an endpoint. Every route named here must exist in the live OpenAPI document, and
  every MCP tool on the public MCP tools page; CI enforces both. Mark unavailable paths as
  unavailable, do not work around them.

- The scripts treat every remote value as untrusted. Check each one against a strict pattern
  before use, numbers as digits only before any bash arithmetic, and stop with a line that names a
  missing field. Run `scripts/check.sh` after any script change.

## Style

- English only. Plain, active sentences. No em dashes.
- Skill frontmatter: one-line quoted `description` that starts with `Trigger:`.
- Keep `SKILL.md` under about 700 tokens. Put detail in a sibling reference file.
- Update this repo when the public contract changes, not before.
