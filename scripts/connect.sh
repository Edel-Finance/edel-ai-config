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
  *)
    echo "usage: scripts/connect.sh <development|testnet> <claude|keychain> [scopes]" >&2
    exit 2
    ;;
esac
case "$target" in
  claude) command -v claude >/dev/null || {
    echo "claude CLI not found" >&2
    exit 2
  } ;;
  keychain) command -v security >/dev/null || {
    echo "macOS security tool not found" >&2
    exit 2
  } ;;
  *)
    echo "target must be claude or keychain" >&2
    exit 2
    ;;
esac
case "$scopes" in
  *[!a-z,]* | "")
    echo "scopes must be a comma separated list such as read,trade" >&2
    exit 2
    ;;
esac

field() {
  # One top-level JSON string or number field, or empty. A missing field is not an error here.
  { printf '%s' "$2" | grep -o "\"$1\":\(\"[^\"]*\"\|[0-9]*\)" || true; } | head -1 | cut -d: -f2- | tr -d '"'
}

safe() {
  # A remote value made safe to print: only letters, digits and . _ : / - survive.
  printf '%s' "$1" | tr -cd 'A-Za-z0-9._:/-' | cut -c1-200
}

need() {
  # Print the field $1 from body $2 when it matches the pattern $3. Otherwise name the field and stop.
  # The value is never printed, because it can be a key.
  local value
  value=$(field "$1" "$2")
  if [ -z "$value" ]; then
    echo "the response has no $1 field. Run the script again or report it with requestId=$(safe "$(field requestId "$2")")" >&2
    exit 1
  fi
  if ! [[ $value =~ $3 ]]; then
    echo "the response field $1 has an unexpected format. Refused." >&2
    exit 1
  fi
  printf '%s' "$value"
}

# Patterns for every remote value the script uses. Numbers are digits only, checked before any
# arithmetic, so a value such as PATH[$(cmd)] can never reach bash arithmetic.
number_re='^[0-9]{1,6}$'
token_re='^[A-Za-z0-9._-]{1,255}$'
user_code_re='^[A-Za-z0-9-]{1,64}$'
url_re='^https://[A-Za-z0-9.-]+(/[A-Za-z0-9._~/?=&%-]*)?$'
key_re='^edel_ak_[A-Za-z0-9_-]{1,255}$'

post() {
  # POST a JSON body read from stdin. Prints the body, then the HTTP status on the last line.
  curl -sS -m 30 -X POST "$api$1" -H 'content-type: application/json' --data @- -w '\n%{http_code}'
}

IFS=' ' read -r -a scope_values <<<"${scopes//,/ }"
scope_list=$(printf '"%s",' "${scope_values[@]}")
answer=$(printf '{"clientName":"edel-ai-config","scopes":[%s]}' "${scope_list%,}" | post /v1/agent-connect/start)
status=${answer##*$'\n'}
body=${answer%$'\n'*}
if [ "$status" != 201 ]; then
  echo "start refused: HTTP $(safe "$status") code=$(safe "$(field code "$body")") requestId=$(safe "$(field requestId "$body")")" >&2
  exit 1
fi
connect_code=$(need connectCode "$body" "$token_re")
interval=$(need intervalSeconds "$body" "$number_re")
expires=$(need expiresInSeconds "$body" "$number_re")
page=$(need verificationUrl "$body" "$url_re")
user_code=$(need userCode "$body" "$user_code_re")
interval=$((10#$interval))
expires=$((10#$expires))
[ "$interval" -ge 1 ] || interval=5

echo "Open this page in your own browser, sign in with your passkey, check the code and approve:"
echo "  page:   $page"
echo "  code:   $user_code"
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
    slow_down) [ "$interval" -ge 60 ] || interval=$((interval + 5)) ;;
    approved)
      api_key=$(need apiKey "$body" "$key_re")
      break
      ;;
    expired)
      echo "The approval expired. Run the script again." >&2
      exit 1
      ;;
    *)
      echo "complete refused: HTTP $(safe "$status") code=$(safe "$(field code "$body")") requestId=$(safe "$(field requestId "$body")")" >&2
      exit 1
      ;;
  esac
done
unset connect_code
case "$api_key" in
  edel_ak_*) ;;
  *)
    echo "No key was approved in time. Run the script again." >&2
    exit 1
    ;;
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
