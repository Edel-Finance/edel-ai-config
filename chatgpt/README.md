# ChatGPT

ChatGPT has two ways in: a custom GPT with Actions, and a custom MCP plugin.

## Custom GPT with Actions (works now)

This GPT reads public TestNet market data through the REST API. It needs no key and cannot trade.

1. In ChatGPT, open Explore GPTs, then Create, then Configure.
2. Paste [instructions.md](instructions.md) into Instructions.
3. Under Actions, choose Create new action. Paste the whole of
   [actions.openapi.json](actions.openapi.json) into Schema. Set Authentication to None.
4. Ask the GPT for the TestNet markets to test it.

For Development, change `servers[0].url` to `https://dev.edel-api.xyz` before you paste.

`actions.openapi.json` is a small read-only subset of the live `GET /openapi.json`, because a GPT
needs only the public reads. The `contract-names` CI check
fails when any operation in it no longer matches the live TestNet contract.

Source: https://help.openai.com/en/articles/9442513 (Configuring actions in GPTs).

## Custom MCP plugin (not yet)

ChatGPT connects a custom MCP server with OAuth 2.1, anonymous access or mTLS. It cannot send a
static API key. The Edel MCP accepts only your own API key in an `Authorization` header, so
ChatGPT cannot connect to it yet. Use another client from the main [README](../README.md) for MCP
tools.

Source: https://developers.openai.com/plugins/build/auth (Authentication) and
https://developers.openai.com/plugins/deploy/connect-chatgpt (Connect and test your plugin).
