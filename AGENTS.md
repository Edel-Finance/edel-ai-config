# Agent rules for edel-ai-config

This repository distributes agent skills for the Edel PERPS public API. Nothing else.

## Scope

- Keep it small: `README.md`, `AGENTS.md`, `.gitignore`, and `skills/<name>/SKILL.md` with its
  local references. Install path is `npx skills add Edel-Finance/edel-ai-config`.
- No application code, CLI, SDK, MCP server, package manifest, lockfile or dependency.
- No copied OpenAPI, AsyncAPI, Postman or realtime contract files. Link to the live docs and the
  live `GET /openapi.json` instead. Copies drift.
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
- Never invent an endpoint. Every route named here must exist in the live OpenAPI document. Mark
  unavailable paths as unavailable, do not work around them.

## Style

- English only. Plain, active sentences. No em dashes.
- Skill frontmatter: one-line quoted `description` that starts with `Trigger:`.
- Keep `SKILL.md` under about 700 tokens. Put detail in a sibling reference file.
- Update this repo when the public contract changes, not before.
