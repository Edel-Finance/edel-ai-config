# Edel public MCP for any client

The Edel MCP is a hosted, stateless Streamable HTTP server. Every request carries your own API key
in `Authorization: Bearer <key>`. The server keeps no session and stores no key. It has no OAuth
flow today: `/.well-known/oauth-protected-resource` answers `404`.

| Environment | URL | Key variable | Keychain service |
| --- | --- | --- | --- |
| MainNet (live, real funds) | `https://mcp.edel-api.xyz/mcp` | `EDEL_MCP_KEY_MAINNET` | `edel-mcp-mainnet` |
| TestNet (test venue) | `https://mcp-testnet.edel-api.xyz/mcp` | `EDEL_MCP_KEY_TESTNET` | `edel-mcp-testnet` |
| Development (test venue) | `https://mcp-dev.edel-api.xyz/mcp` | `EDEL_MCP_KEY_DEVELOPMENT` | `edel-mcp-development` |

## Set up

1. Get your own key and save it in the macOS login Keychain. You approve the printed code in your
   own browser with your passkey:

   ```sh
   scripts/connect.sh mainnet keychain
   scripts/connect.sh testnet keychain
   scripts/connect.sh development keychain
   ```

   The default scope is `read`. Pass a third argument such as `read,trade` only when you need it.
   `agents` and `funding` are opt-in. Read the scope table in the docs before you ask for one.
   On another OS, follow the device grant in
   <https://docs.edel.finance/developers/accounts/for-agents> and keep the key in your own
   secret store.

2. Load the key into your shell from the Keychain. Add these lines to your shell profile. The key
   never appears on a command line:

   ```sh
   export EDEL_MCP_KEY_MAINNET="$(security find-generic-password -a "$USER" -s edel-mcp-mainnet -w 2>/dev/null)"
   export EDEL_MCP_KEY_TESTNET="$(security find-generic-password -a "$USER" -s edel-mcp-testnet -w 2>/dev/null)"
   export EDEL_MCP_KEY_DEVELOPMENT="$(security find-generic-password -a "$USER" -s edel-mcp-development -w 2>/dev/null)"
   ```

3. Copy the entries from [servers.json](servers.json) into your client's MCP config. The file uses
   `${VAR}` expansion. If your client uses another syntax (for example `${env:VAR}`), change only
   that part. Never paste the key itself into the file.

4. Start your client. It must start from a shell that has the variables from step 2.

## Smoke test

```sh
scripts/smoke.sh mainnet testnet development
```

Per environment it reads `/ready`, checks that `/mcp` refuses a request with no key (`401` with
`nextTool: edel_connect`), and, when the key variable is set, lists the tools and calls the
read-only tool `edel_markets`. The key reaches `curl` on stdin. The output holds only statuses,
counts, booleans, `reason`, `nextTool` and `requestId`.
