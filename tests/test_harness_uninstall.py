import hashlib
import importlib.machinery
import importlib.util
import json
import os
import shutil
import stat
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).parents[1]


class HarnessUninstallTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.home = Path(self.temp.name) / "home"
        self.bundle = Path(self.temp.name) / "bundle"
        self.installer = self.bundle / "scripts/harness-uninstall"
        self.installer.parent.mkdir(parents=True)
        shutil.copyfile(ROOT / "scripts/harness-uninstall", self.installer)
        os.chmod(self.installer, 0o755)
        self.env = {**os.environ, "HOME": str(self.home), "PYTHONDONTWRITEBYTECODE": "1"}

    def tearDown(self):
        self.temp.cleanup()

    def target(self, relative):
        return self.home / ".codex" / relative

    def invoke(self, argument):
        return subprocess.run([str(self.installer), argument], env=self.env, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)

    def provision(self):
        artifacts = (
            ("AGENTS.md", b"old global\n", 0o644),
            ("harness/bin/telemetry-record", b"old handler\n", 0o700),
            ("hooks.json", b'{"old":"hooks"}\n', 0o644),
        )
        records = {}
        for relative, content, mode in artifacts:
            target = self.target(relative); target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(content); os.chmod(target, mode)
            name = {"AGENTS.md": "global-agents", "harness/bin/telemetry-record": "telemetry-handler", "hooks.json": "hooks-json"}[relative]
            records[name] = {"sha256": hashlib.sha256(content).hexdigest(), "mode": mode}
        manifest = self.target("harness/managed-artifacts.json")
        manifest.write_text(json.dumps({"schema_version": 1, "artifacts": records}), encoding="utf-8")
        os.chmod(manifest, 0o600)
        telemetry = self.target("harness/telemetry")
        telemetry.mkdir(parents=True, exist_ok=True)
        (telemetry / "enabled").write_bytes(b"enabled\n")
        (telemetry / "turns.jsonl").write_text('{"turn":1}\n', encoding="utf-8")
        (telemetry / "tasks.jsonl").write_text('{"legacy":1}\n', encoding="utf-8")
        (telemetry / "turn-state").mkdir()
        return artifacts

    def test_complete_repeated_uninstall_and_telemetry_preservation(self):
        artifacts = self.provision()
        self.assertEqual(self.invoke("--check").returncode, 1)
        applied = self.invoke("--apply")
        self.assertEqual(applied.returncode, 0, applied.stdout + applied.stderr)
        for relative, _, _ in artifacts:
            self.assertFalse(self.target(relative).exists())
        self.assertFalse(self.target("harness/managed-artifacts.json").exists())
        self.assertEqual(self.target("harness/telemetry/enabled").read_bytes(), b"enabled\n")
        self.assertEqual(self.target("harness/telemetry/turns.jsonl").read_text(), '{"turn":1}\n')
        self.assertEqual(self.target("harness/telemetry/tasks.jsonl").read_text(), '{"legacy":1}\n')
        self.assertTrue(self.target("harness/telemetry/turn-state").is_dir())
        self.assertEqual(self.invoke("--check").returncode, 0)
        self.assertEqual(self.invoke("--apply").returncode, 0)

    def test_clean_without_manifest_is_not_installed_but_target_is_unmanaged(self):
        self.assertEqual(self.invoke("--check").returncode, 0)
        self.assertEqual(self.invoke("--apply").returncode, 0)
        target = self.target("AGENTS.md"); target.parent.mkdir(parents=True); target.write_text("user file\n", encoding="utf-8")
        check = self.invoke("--check")
        self.assertEqual(check.returncode, 3, check.stdout + check.stderr)
        self.assertIn("global-agents\tUNMANAGED", check.stdout)
        self.assertEqual(self.invoke("--apply").returncode, 3)
        self.assertTrue(target.exists())

    def test_modified_and_already_absent_targets(self):
        self.provision()
        global_target = self.target("AGENTS.md")
        global_target.write_text("user edit\n", encoding="utf-8")
        self.assertEqual(self.invoke("--check").returncode, 3)
        self.assertEqual(self.invoke("--apply").returncode, 3)
        self.assertTrue(self.target("harness/managed-artifacts.json").exists())

        self.temp.cleanup(); self.setUp()
        self.provision()
        self.target("harness/bin/telemetry-record").unlink()
        check = self.invoke("--check")
        self.assertEqual(check.returncode, 1, check.stdout + check.stderr)
        self.assertIn("telemetry-handler\tALREADY_ABSENT", check.stdout)
        self.assertEqual(self.invoke("--apply").returncode, 0)

    def test_corrupt_manifest_and_source_independent_baseline(self):
        self.provision()
        manifest = self.target("harness/managed-artifacts.json")
        manifest.write_text('{"schema_version":1,"artifacts":{}}', encoding="utf-8")
        self.assertEqual(self.invoke("--check").returncode, 2)
        self.assertTrue(self.target("AGENTS.md").exists())

        self.temp.cleanup(); self.setUp()
        self.provision()
        # The bundle deliberately contains no Harness source templates; removal
        # succeeds solely from the prior manifest baseline.
        self.assertEqual(self.invoke("--apply").returncode, 0)

    def test_partial_failure_rolls_back(self):
        self.provision()
        loader = importlib.machinery.SourceFileLoader("harness_uninstall_test", str(self.installer))
        spec = importlib.util.spec_from_loader(loader.name, loader)
        module = importlib.util.module_from_spec(spec); loader.exec_module(module)
        items = module.targets(self.home)
        manifest_path = self.target("harness/managed-artifacts.json")
        manifest, fingerprint = module.load_manifest(manifest_path, items)
        entries = module.evaluate(items, manifest)
        calls = 0

        def fail_second(source, target):
            nonlocal calls
            calls += 1
            if calls == 2:
                raise OSError("injected detach failure")
            os.replace(source, target)

        ok, detail = module.detach(entries, manifest, manifest_path, fingerprint, replace=fail_second)
        self.assertFalse(ok); self.assertIn("apply failed", detail)
        self.assertTrue(self.target("AGENTS.md").exists())
        self.assertTrue(self.target("harness/bin/telemetry-record").exists())
        self.assertTrue(self.target("hooks.json").exists())
        self.assertTrue(manifest_path.exists())


if __name__ == "__main__":
    unittest.main()
