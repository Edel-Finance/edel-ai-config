#!/usr/bin/env bash
# Offline checks for connect.sh and smoke.sh. No network, no key, no browser.
#
# Usage: scripts/check.sh
#
# A fake curl on PATH returns crafted responses. The checks prove that a remote number such as
# PATH[$(cmd)] is refused before any bash arithmetic, and that a missing field stops the script with
# a line that names the field.
set +x
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir "$work/bin"
marker="$work/injected"

cat >"$work/bin/curl" <<'STUB'
#!/usr/bin/env bash
# Fake curl. FAKE_CASE picks the response. It drains stdin only when the caller pipes into it.
url="" data=""
while [ $# -gt 0 ]; do
  case "$1" in
    --data) data="$2"; [ "$2" != @- ] || cat >/dev/null; shift ;;
    --config) cat >/dev/null; shift ;;
    http*) url="$1" ;;
  esac
  shift
done
start='"connectCode":"cc_1","verificationUrl":"https://dev.example/connect","userCode":"ABCD-1234"'
case "$FAKE_CASE:$url" in
  interval:*/v1/agent-connect/start) printf '{%s,"intervalSeconds":"PATH[$(touch %s)]","expiresInSeconds":5}\n201' "$start" "$FAKE_MARKER" ;;
  expires:*/v1/agent-connect/start) printf '{%s,"intervalSeconds":1,"expiresInSeconds":"PATH[$(touch %s)]"}\n201' "$start" "$FAKE_MARKER" ;;
  missing:*/v1/agent-connect/start) printf '{"verificationUrl":"https://dev.example/connect","userCode":"ABCD-1234","intervalSeconds":1,"expiresInSeconds":5}\n201' ;;
  notools:*/ready) printf '{"status":"ok"}' ;;
  notools:*/mcp)
    case "$data" in
      *initialize*) printf '{"result":{}}\n200' ;;
      *tools/list*) printf '{"result":{}}\n200' ;;
      *) printf '{}\n500' ;;
    esac ;;
  *) printf '{}\n500' ;;
esac
STUB
printf '#!/usr/bin/env bash\ncat >/dev/null\n' >"$work/bin/claude"
chmod +x "$work/bin/curl" "$work/bin/claude"

failures=0
expect_refused() {
  # $1 name, $2 text the error must contain, then the command.
  local name="$1" want="$2" out code=0
  shift 2
  out=$(PATH="$work/bin:$PATH" FAKE_MARKER="$marker" "$@" 2>&1) || code=$?
  if [ "$code" -ne 0 ] && [[ $out == *"$want"* ]] && [ ! -e "$marker" ]; then
    echo "ok: $name"
  else
    echo "FAIL: $name (exit $code, injected=$([ -e "$marker" ] && echo true || echo false))"
    printf '%s\n' "$out" | sed 's/^/  /'
    failures=$((failures + 1))
  fi
  rm -f "$marker"
}

expect_refused "intervalSeconds injection is refused" "intervalSeconds has an unexpected format" \
  env FAKE_CASE=interval bash "$root/scripts/connect.sh" development claude
expect_refused "expiresInSeconds injection is refused" "expiresInSeconds has an unexpected format" \
  env FAKE_CASE=expires bash "$root/scripts/connect.sh" development claude
expect_refused "missing connectCode is named" "has no connectCode field" \
  env FAKE_CASE=missing bash "$root/scripts/connect.sh" development claude
expect_refused "missing tool names are named" "no result.tools[].name field" \
  env FAKE_CASE=notools EDEL_MCP_KEY_DEVELOPMENT=fake bash "$root/scripts/smoke.sh" development

echo "failures: $failures"
[ "$failures" = 0 ]
