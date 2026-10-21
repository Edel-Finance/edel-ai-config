"""Fail when a skill names an MCP tool or a REST route that the published contract lacks.

Sources are public and need no secret:
- REST routes: the live OpenAPI document of the venue named by EDEL_OPENAPI_URL.
- MCP tools: the public MCP tools docs page named by EDEL_MCP_TOOLS_URL.
"""

import json
import os
import pathlib
import re
import sys
import urllib.request

OPENAPI_URL = os.environ.get("EDEL_OPENAPI_URL", "https://testnet.edel-api.xyz/openapi.json")
MCP_TOOLS_URL = os.environ.get(
    "EDEL_MCP_TOOLS_URL", "https://docs.edel.finance/developers/mcp/tools"
)
ROOT_DIR = pathlib.Path(__file__).resolve().parents[2]
SKILLS_DIRS = (ROOT_DIR / "skills", ROOT_DIR / ".openclaw" / "skills")

TOOL_RE = re.compile(r"`(edel_[a-z][a-z0-9_]*)`")
ROUTE_RE = re.compile(r"`(GET|POST|PUT|PATCH|DELETE) (/[A-Za-z0-9_\-/{}:.]*)`")
METHODS = {"get", "post", "put", "patch", "delete"}


def fetch(url):
    request = urllib.request.Request(url, headers={"User-Agent": "edel-ai-config-ci"})
    with urllib.request.urlopen(request, timeout=30) as response:
        return response.read().decode("utf-8")


def normalize(path):
    path = re.sub(r"\{[^}]+\}", "{}", path)
    return re.sub(r":[A-Za-z_][A-Za-z0-9_]*", "{}", path)


def main():
    spec = json.loads(fetch(OPENAPI_URL))
    known_routes = {
        f"{method.upper()} {normalize(path)}"
        for path, operations in spec["paths"].items()
        for method in operations
        if method in METHODS
    }
    known_tools = set(re.findall(r"\bedel_[a-z][a-z0-9_]*\b", fetch(MCP_TOOLS_URL)))
    if not known_tools:
        print(f"No tool names found at {MCP_TOOLS_URL}")
        return 1

    missing = []
    docs = [doc for skills_dir in SKILLS_DIRS if skills_dir.exists() for doc in sorted(skills_dir.rglob("*.md"))]
    for doc in docs:
        text = doc.read_text(encoding="utf-8")
        rel = doc.relative_to(ROOT_DIR)
        for tool in sorted(set(TOOL_RE.findall(text))):
            if tool not in known_tools:
                missing.append(f"{rel}: MCP tool {tool} is not on {MCP_TOOLS_URL}")
        for method, path in sorted(set(ROUTE_RE.findall(text))):
            route = f"{method} {normalize(path)}"
            if route not in known_routes:
                missing.append(f"{rel}: route {method} {path} is not in {OPENAPI_URL}")

    # The ChatGPT Actions schema is a hand-kept subset, so each operation must match the live one.
    live_ops = {
        operation.get("operationId"): (method, normalize(path), {p.get("name") for p in operation.get("parameters", [])})
        for path, operations in spec["paths"].items()
        for method, operation in operations.items()
        if method in METHODS
    }
    actions_file = ROOT_DIR / "chatgpt" / "actions.openapi.json"
    for path, operations in json.loads(actions_file.read_text(encoding="utf-8"))["paths"].items():
        for method, operation in operations.items():
            op_id = operation["operationId"]
            params = {p["name"] for p in operation.get("parameters", [])}
            live = live_ops.get(op_id)
            if method != "get" or not live or live[:2] != (method, normalize(path)) or not params <= live[2]:
                missing.append(f"chatgpt/actions.openapi.json: {method.upper()} {path} ({op_id}) does not match {OPENAPI_URL}")

    for line in missing:
        print(line)
    print(f"Checked against {len(known_routes)} routes and {len(known_tools)} tools.")
    return 1 if missing else 0


if __name__ == "__main__":
    sys.exit(main())
