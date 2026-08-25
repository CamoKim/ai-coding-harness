import importlib.machinery
import importlib.util
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

SOURCE_ROOT = Path(__file__).parents[1]


class HarnessInstallTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name) / "bundle"
        self.home = Path(self.temp.name) / "home"
        for relative in ("scripts/harness-install", "scripts/telemetry-record", "templates/global/AGENTS.md", "templates/telemetry/hooks.json"):
            target = self.root / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(SOURCE_ROOT / relative, target)
        os.chmod(self.root / "scripts/harness-install", 0o755)
        self.installer = self.root / "scripts/harness-install"
        self.env = {**os.environ, "HOME": str(self.home), "PYTHONDONTWRITEBYTECODE": "1"}

    def tearDown(self):
        self.temp.cleanup()

    def invoke(self, argument):
        return subprocess.run([str(self.installer), argument], env=self.env, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)

    def target(self, relative):
        return self.home / ".codex" / relative

    def install(self):
        result = self.invoke("--apply")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_first_install_and_manifest_adoption(self):
        check = self.invoke("--check")
        self.assertEqual(check.returncode, 1, check.stdout + check.stderr)
        self.assertIn("global-agents\tMISSING", check.stdout)
        self.install()
        self.assertEqual(self.invoke("--check").returncode, 0)

        shutil.rmtree(self.home / ".codex")
        targets = (
            ("AGENTS.md", self.root / "templates/global/AGENTS.md", 0o644),
            ("harness/bin/telemetry-record", self.root / "scripts/telemetry-record", 0o700),
            ("hooks.json", self.root / "templates/telemetry/hooks.json", 0o644),
        )
        inodes = {}
        for relative, source, mode in targets:
            target = self.target(relative); target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source, target); os.chmod(target, mode); inodes[relative] = target.stat().st_ino
        self.assertIn("global-agents\tADOPTABLE", self.invoke("--check").stdout)
        self.install()
        self.assertTrue((self.target("harness/managed-artifacts.json")).is_file())
        self.assertEqual({relative: self.target(relative).stat().st_ino for relative, _, _ in targets}, inodes)

    def test_safe_upgrade_and_unmanaged_edit(self):
        self.install()
        source = self.root / "templates/global/AGENTS.md"
        source.write_text(source.read_text(encoding="utf-8") + "\n# upgraded\n", encoding="utf-8")
        check = self.invoke("--check")
        self.assertEqual(check.returncode, 1, check.stdout + check.stderr)
        self.assertIn("global-agents\tSAFE_UPGRADE", check.stdout)
        self.install()
        target = self.target("AGENTS.md")
        target.write_text(target.read_text(encoding="utf-8") + "user edit\n", encoding="utf-8")
        manifest = self.target("harness/managed-artifacts.json").read_bytes()
        check = self.invoke("--check")
        self.assertEqual(check.returncode, 3, check.stdout + check.stderr)
        self.assertIn("global-agents\tUNMANAGED_DRIFT", check.stdout)
        self.assertEqual(self.invoke("--apply").returncode, 3)
        self.assertEqual(self.target("harness/managed-artifacts.json").read_bytes(), manifest)

    def test_managed_deletion_and_hooks_conflict_block_apply(self):
        self.install()
        self.target("harness/bin/telemetry-record").unlink()
        check = self.invoke("--check")
        self.assertEqual(check.returncode, 3, check.stdout + check.stderr)
        self.assertIn("telemetry-handler\tUNMANAGED_DRIFT", check.stdout)
        self.assertEqual(self.invoke("--apply").returncode, 3)
        self.assertFalse(self.target("harness/bin/telemetry-record").exists())

        clean = tempfile.TemporaryDirectory(); self.addCleanup(clean.cleanup)
        self.home = Path(clean.name); self.env["HOME"] = str(self.home)
        self.target("config.toml").parent.mkdir(parents=True)
        self.target("config.toml").write_text("[hooks]\n", encoding="utf-8")
        self.assertEqual(self.invoke("--apply").returncode, 3)
        self.assertFalse(self.target("AGENTS.md").exists())

    def test_partial_failure_rolls_back(self):
        loader = importlib.machinery.SourceFileLoader("harness_install_test", str(self.installer))
        spec = importlib.util.spec_from_loader(loader.name, loader)
        module = importlib.util.module_from_spec(spec); loader.exec_module(module)
        items = module.evaluate(module.artifacts(self.home), None, self.target("config.toml"))
        calls = 0

        def fail_second(source, target):
            nonlocal calls
            calls += 1
            if calls == 2:
                raise OSError("injected replacement failure")
            os.replace(source, target)

        ok, detail = module.apply(items, None, self.target("harness/managed-artifacts.json"), self.target("config.toml"), replace=fail_second)
        self.assertFalse(ok); self.assertIn("apply failed", detail)
        self.assertFalse(self.target("AGENTS.md").exists())
        self.assertFalse(self.target("harness/bin/telemetry-record").exists())
        self.assertFalse(self.target("harness/managed-artifacts.json").exists())


if __name__ == "__main__":
    unittest.main()
