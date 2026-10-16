#!/usr/bin/env bash
# Smoke test for the Edel public MCP servers.
#
# Usage: scripts/smoke.sh [development] [testnet]   (default: both)
#
# Per environment it checks /ready, checks that /mcp refuses a request with no key, and, when the
# key variable is set, lists the tools and calls the read-only tool edel_markets.
# The key comes from the environment only (EDEL_MCP_KEY_DEVELOPMENT, EDEL_MCP_KEY_TESTNET). It
# reaches curl on stdin, never on the command line, and is never printed. Output holds only
# statuses, counts, booleans and the refusal reason.
set +x
set -euo pipefail

endpoint() {
  case "$1" in
    development) echo "https://mcp-dev.edel-api.xyz" ;;
    testnet) echo "https://mcp-testnet.edel-api.xyz" ;;
    production) echo "" ;;
    *) echo "unknown environment: $1" >&2; exit 2 ;;
  esac
}

key_var() {
  case "$1" in
    development) echo "EDEL_MCP_KEY_DEVELOPMENT" ;;
    testnet) echo "EDEL_MCP_KEY_TESTNET" ;;
    production) echo "EDEL_MCP_KEY_PRODUCTION" ;;
  esac
}

field() {
  # Print one top-level JSON string or boolean field, or "-" when it is absent.
  local value
  value=$(printf '%s' "$2" | grep -o "\"$1\":\(\"[^\"]*\"\|true\|false\|null\)" | head -1 | cut -d: -f2- | tr -d '"')
  printf '%s' "${value:--}"
}

# POST one JSON-RPC body to /mcp. The Authorization header travels in a curl config read from stdin.
rpc() {
  local origin="$1" key="$2" body="$3"
  if [ -n "$key" ]; then
    printf 'header = "Authorization: Bearer %s"\n' "$key" |
      curl -sS -m 30 --config - -X POST "$origin/mcp" \
        -H 'content-type: application/json' \
        -H 'accept: application/json, text/event-stream' \
        --data "$body" -w '\n%{http_code}'
  else
    curl -sS -m 30 -X POST "$origin/mcp" \
      -H 'content-type: application/json' \
      -H 'accept: application/json, text/event-stream' \
      --data "$body" -w '\n%{http_code}'
  fi
}

root="$(cd "$(dirname "$0")/.." && pwd)"
failures=0

smoke() {
  local env="$1" origin var key answer status payload
  origin=$(endpoint "$env")
  echo "== $env"
  if [ -z "$origin" ]; then
    echo "skipped: no public MCP for $env yet"
    return
  fi
  echo "origin: $origin/mcp"
  local file
  for file in .claude-plugin/plugin.json mcp/servers.json; do
    if ! grep -q "\"$origin/mcp\"" "$root/$file"; then
      echo "config drift: $file does not name $origin/mcp"
      failures=$((failures + 1))
    fi
  done

  payload=$(curl -sS -m 15 "$origin/ready" || true)
  echo "ready: $(field status "$payload")"

  answer=$(rpc "$origin" "" '{"jsonrpc":"2.0","id":1,"method":"tools/list"}')
  status=${answer##*$'\n'}
  payload=${answer%$'\n'*}
  echo "no key: HTTP $status reason=$(field reason "$payload")"
  [ "$status" = 401 ] || failures=$((failures + 1))

  var=$(key_var "$env")
  key="${!var:-}"
  if [ -z "$key" ]; then
    echo "with key: skipped, $var is not set"
    return
  fi

  answer=$(rpc "$origin" "$key" '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"edel-ai-config-smoke","version":"1"}}}')
  status=${answer##*$'\n'}
  echo "initialize: HTTP $status"
  if [ "$status" != 200 ]; then
    payload=${answer%$'\n'*}
    echo "refused: reason=$(field reason "$payload") apiKeyRejection=$(field apiKeyRejection "$payload") requestId=$(field requestId "$payload")"
    failures=$((failures + 1))
    return
  fi

  answer=$(rpc "$origin" "$key" '{"jsonrpc":"2.0","id":2,"method":"tools/list"}')
  status=${answer##*$'\n'}
  payload=${answer%$'\n'*}
  local tools
  tools=$(printf '%s' "$payload" | grep -o '"name":"edel_[a-z_]*"' | sort -u | wc -l | tr -d ' ')
  echo "tools/list: HTTP $status tools=$tools edel_markets=$(printf '%s' "$payload" | grep -q '"name":"edel_markets"' && echo true || echo false)"
  [ "$status" = 200 ] && [ "$tools" -gt 0 ] || failures=$((failures + 1))

  answer=$(rpc "$origin" "$key" '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"edel_markets","arguments":{}}}')
  status=${answer##*$'\n'}
  payload=${answer%$'\n'*}
  echo "edel_markets: HTTP $status isError=$(field isError "$payload")"
  [ "$status" = 200 ] && [ "$(field isError "$payload")" != true ] || failures=$((failures + 1))
}

envs=("$@")
[ "${#envs[@]}" -gt 0 ] || envs=(development testnet)
for env in "${envs[@]}"; do
  smoke "$env"
done

echo "failures: $failures"
[ "$failures" = 0 ]
