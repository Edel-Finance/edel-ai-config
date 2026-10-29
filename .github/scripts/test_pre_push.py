"""Offline process controls for the pre-push safety boundary."""

import contextlib
import io
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from types import SimpleNamespace

from pre_push import clean_environment, gate, git, receipt


def commit(root, message):
    (root / "fixture.txt").write_text(message)
    git(root, "add", "fixture.txt")
    git(
        root,
        "-c",
        "user.name=Offline Fixture",
        "-c",
        "user.email=fixture@example.invalid",
        "commit",
        "--quiet",
        "-m",
        message,
    )


def repository(root):
    subprocess.run(
        ["git", "init", "--quiet", str(root)],
        env=clean_environment(os.environ),
        check=True,
    )
    commit(root, "first")


class OfflineGateTests(unittest.TestCase):
    def test_child_git_cannot_modify_parent(self):
        with (
            tempfile.TemporaryDirectory() as parent,
            tempfile.TemporaryDirectory() as child,
        ):
            root = Path(parent)
            repository(root)
            before = receipt(root)
            inherited = dict(
                os.environ,
                GIT_DIR=git(root, "rev-parse", "--absolute-git-dir"),
                GIT_WORK_TREE=parent,
                GIT_INDEX_FILE=str(root / ".git/index"),
                GIT_CONFIG_COUNT="1",
                GIT_CONFIG_KEY_0="core.bare",
                GIT_CONFIG_VALUE_0="false",
                NODE_OPTIONS="--import /absolute/offline-guard.mjs",
            )
            calls = []

            def run(command, cwd, env):
                self.assertFalse(any(key.startswith("GIT_") for key in env))
                self.assertEqual(env["NODE_OPTIONS"], inherited["NODE_OPTIONS"])
                calls.append(command)
                if len(calls) == 1:
                    subprocess.run(
                        ["git", "init", "--quiet", child], env=env, check=True
                    )
                    subprocess.run(
                        [
                            "git",
                            "-C",
                            child,
                            "-c",
                            "user.name=Offline Fixture",
                            "-c",
                            "user.email=fixture@example.invalid",
                            "commit",
                            "--allow-empty",
                            "--quiet",
                            "-m",
                            "child",
                        ],
                        env=env,
                        check=True,
                    )
                return SimpleNamespace(returncode=0)

            with contextlib.redirect_stdout(io.StringIO()):
                self.assertEqual(gate(root, run, inherited), 0)
            self.assertEqual(receipt(root), before)
            self.assertEqual(git(Path(child), "log", "-1", "--format=%s"), "child")
            self.assertEqual(len(calls), 7)

    def test_successful_checks_with_mutation_fail_without_restoration(self):
        with tempfile.TemporaryDirectory() as parent:
            root = Path(parent)
            repository(root)
            before = receipt(root)
            calls = []

            def run(command, cwd, env):
                if not calls:
                    commit(root, "second")
                calls.append(command)
                return SimpleNamespace(returncode=0)

            with contextlib.redirect_stdout(io.StringIO()):
                self.assertEqual(gate(root, run), 1)
            self.assertNotEqual(receipt(root), before)
            self.assertEqual(git(root, "log", "-1", "--format=%s"), "second")

    def test_failed_check_stops_before_later_commands(self):
        with tempfile.TemporaryDirectory() as parent:
            root = Path(parent)
            repository(root)
            calls = []

            def run(command, cwd, env):
                calls.append(command)
                return SimpleNamespace(returncode=7)

            with contextlib.redirect_stdout(io.StringIO()):
                self.assertEqual(gate(root, run), 7)
            self.assertEqual(len(calls), 1)


if __name__ == "__main__":
    unittest.main()
