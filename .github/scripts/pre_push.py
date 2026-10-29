"""Read-only offline gate with hook-local Git isolation and mutation detection."""

import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys


def clean_environment(environment):
    return {
        key: value for key, value in environment.items() if not key.startswith("GIT_")
    }


def git(root, *arguments):
    result = subprocess.run(
        ["git", "-C", str(root), *arguments],
        env=clean_environment(os.environ),
        check=True,
        capture_output=True,
        text=True,
    )
    return result.stdout.strip()


def receipt(root):
    index = Path(git(root, "rev-parse", "--git-path", "index"))
    if not index.is_absolute():
        index = root / index
    return {
        "head": git(root, "rev-parse", "HEAD"),
        "index": hashlib.sha256(index.read_bytes()).hexdigest(),
    }


def gate(root, run=subprocess.run, environment=None):
    before = receipt(root)
    environment = clean_environment(os.environ if environment is None else environment)
    commands = [
        [
            "npm",
            "exec",
            "--offline",
            "--package",
            "prettier@3.9.10",
            "--",
            "prettier",
            "--check",
            "CODING_STANDARDS.md",
            "GLOSSARY.md",
            "AGENTS.md",
            ".github/pull_request_template.md",
        ],
        [
            "shfmt",
            "-i",
            "2",
            "-ci",
            "-d",
            "scripts/connect.sh",
            "scripts/check.sh",
            ".githooks/pre-push",
        ],
        [
            "shellcheck",
            "scripts/connect.sh",
            "scripts/check.sh",
            "scripts/smoke.sh",
            ".githooks/pre-push",
        ],
        [
            "ruff",
            "check",
            ".github/scripts/pre_push.py",
            ".github/scripts/test_pre_push.py",
        ],
        [
            "ruff",
            "format",
            "--check",
            ".github/scripts/pre_push.py",
            ".github/scripts/test_pre_push.py",
        ],
        ["bash", "scripts/check.sh"],
        [
            "python3",
            "-m",
            "unittest",
            "discover",
            "-s",
            ".github/scripts",
            "-p",
            "test_pre_push.py",
        ],
    ]
    status = 1
    try:
        for command in commands:
            status = run(command, cwd=root, env=environment).returncode
            if status:
                break
    finally:
        after = receipt(root)
        unchanged = before == after
        print(
            json.dumps(
                {
                    "event": "offline_gate_git_invariant",
                    "before": before,
                    "after": after,
                    "unchanged": unchanged,
                }
            )
        )
        if not unchanged:
            status = 1
    return status


if __name__ == "__main__":
    try:
        sys.exit(gate(Path(__file__).resolve().parents[2]))
    except (OSError, subprocess.SubprocessError):
        print("offline_gate_failed", file=sys.stderr)
        sys.exit(1)
