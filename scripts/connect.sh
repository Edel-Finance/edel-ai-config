#!/usr/bin/env bash
# Get your own Edel API key for the public MCP and store it without printing it.
#
# Usage: scripts/connect.sh <development|testnet> <claude|keychain> [scopes]
#
#   claude    saves the key into the Claude Code plugin option (OS secure credential store).
#   keychain  saves the key in the macOS login Keychain, service edel-mcp-<environment>.
#   scopes    comma separated, default read. Add a scope only if the live contract lists it and you need it.
#
# It runs the public device grant: POST /v1/agent-connect/start, then you approve the printed code
# in your own browser with your passkey, then POST /v1/agent-connect/complete returns the key once.
# This script never opens a browser. The key and the connect code travel on stdin only, never on a
# command line, and are never printed.
set +x
set -euo pipefail

env_name="${1:-}"
target="${2:-}"
scopes="${3:-read}"

case "$env_name" in
  development) api="https://dev.edel-api.xyz" ;;
  testnet) api="https://testnet.edel-api.xyz" ;;
  *) echo "usage: scripts/connect.sh <development|testnet> <claude|keychain> [scopes]" >&2; exit 2 ;;
esac
case "$target" in
  claude) command -v claude >/dev/null || { echo "claude CLI not found" >&2; exit 2; } ;;
  keychain) command -v security >/dev/null || { echo "macOS security tool not found" >&2; exit 2; } ;;
  *) echo "target must be claude or keychain" >&2; exit 2 ;;
esac
case "$scopes" in
  *[!a-z,]*|"") echo "scopes must be a comma separated list such as read,trade" >&2; exit 2 ;;
esac

field() {
  # One top-level JSON string or number field, or empty.
  printf '%s' "$2" | grep -o "\"$1\":\(\"[^\"]*\"\|[0-9]*\)" | head -1 | cut -d: -f2- | tr -d '"'
}

post() {
  # POST a JSON body read from stdin. Prints the body, then the HTTP status on the last line.
  curl -sS -m 30 -X POST "$api$1" -H 'content-type: application/json' --data @- -w '\n%{http_code}'
}

scope_list=$(printf '"%s",' ${scopes//,/ })
answer=$(printf '{"clientName":"edel-ai-config","scopes":[%s]}' "${scope_list%,}" | post /v1/agent-connect/start)
status=${answer##*$'\n'}
body=${answer%$'\n'*}
if [ "$status" != 201 ]; then
  echo "start refused: HTTP $status code=$(field code "$body") requestId=$(field requestId "$body")" >&2
  exit 1
fi
connect_code=$(field connectCode "$body")
interval=$(field intervalSeconds "$body")
expires=$(field expiresInSeconds "$body")

echo "Open this page in your own browser, sign in with your passkey, check the code and approve:"
echo "  page:   $(field verificationUrl "$body")"
echo "  code:   $(field userCode "$body")"
echo "  scopes: $scopes"
echo "Waiting up to ${expires}s for your approval."

deadline=$((SECONDS + expires))
api_key=""
while [ "$SECONDS" -lt "$deadline" ]; do
  sleep "$interval"
  answer=$(printf '{"connectCode":"%s"}' "$connect_code" | post /v1/agent-connect/complete)
  status=${answer##*$'\n'}
  body=${answer%$'\n'*}
  case "$(field status "$body")" in
    authorization_pending) ;;
    slow_down) interval=$((interval + 5)) ;;
    approved) api_key=$(field apiKey "$body"); break ;;
    expired) echo "The approval expired. Run the script again." >&2; exit 1 ;;
    *) echo "complete refused: HTTP $status code=$(field code "$body") requestId=$(field requestId "$body")" >&2; exit 1 ;;
  esac
done
unset connect_code
case "$api_key" in
  edel_ak_*) ;;
  *) echo "No key was approved in time. Run the script again." >&2; exit 1 ;;
esac

case "$target" in
  claude)
    option="${env_name}_api_key"
    printf '{"%s":"%s"}' "$option" "$api_key" | claude plugin configure edel@edel-ai-config --values-stdin >/dev/null
    echo "Saved in the Claude Code plugin option $option. Restart Claude Code."
    ;;
  keychain)
    printf 'add-generic-password -U -a "%s" -s "edel-mcp-%s" -w "%s"\n' "$USER" "$env_name" "$api_key" | security -i >/dev/null
    echo "Saved in the macOS login Keychain, service edel-mcp-$env_name."
    ;;
esac
unset api_key
