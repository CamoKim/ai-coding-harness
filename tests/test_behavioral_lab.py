import json
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).parents[1]
LAB = ROOT / "scripts/behavioral-lab"


class BehavioralLabTest(unittest.TestCase):
    def prepare(self, scenario):
        result = subprocess.run([str(LAB), "prepare", scenario], text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        workspace = Path(result.stdout.splitlines()[0])
        self.addCleanup(lambda: __import__("shutil").rmtree(workspace.parent, ignore_errors=True))
        return workspace

    def check(self, workspace):
        return subprocess.run([str(LAB), "check", str(workspace)], text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)

    def assert_no_bytecode(self, workspace):
        artifacts = [path.relative_to(workspace) for path in workspace.rglob("__pycache__")]
        artifacts.extend(path.relative_to(workspace) for path in workspace.rglob("*.pyc"))
        self.assertEqual(artifacts, [])

    def test_all_scenarios_prepare_with_metadata_only(self):
        for name in ("trivial", "standard", "shared-impact", "runtime-boundary", "high-risk"):
            workspace = self.prepare(name)
            metadata = json.loads((workspace / ".behavioral-lab/scenario.json").read_text())
            self.assertEqual(metadata["id"], name)

    def test_trivial_passes_from_diff_and_verify_event(self):
        workspace = self.prepare("trivial")
        (workspace / "docs/README.md").write_text("Color guide\n", encoding="utf-8")
        subprocess.run(["./scripts/verify", "docs", "fast"], cwd=workspace, check=True)
        result = self.check(workspace)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_standard_and_shared_consumer_routing(self):
        standard = self.prepare("standard")
        (standard / "app/normalize.py").write_text("def normalize(value):\n    return value.strip()\n", encoding="utf-8")
        subprocess.run(["./scripts/verify", "app", "fast"], cwd=standard, check=True)
        self.assertEqual(self.check(standard).returncode, 0)
        self.assert_no_bytecode(standard)

        shared = self.prepare("shared-impact")
        (shared / "shared/format.py").write_text("def label(value):\n    return value.lower()\n", encoding="utf-8")
        subprocess.run(["./scripts/verify", "alpha", "fast"], cwd=shared, check=True)
        subprocess.run(["./scripts/verify", "beta", "fast"], cwd=shared, check=True)
        self.assertEqual(self.check(shared).returncode, 0)
        self.assert_no_bytecode(shared)

    def test_runtime_requires_isolated_event_and_high_risk_attestation(self):
        workspace = self.prepare("runtime-boundary")
        (workspace / "runtime/adapter.py").write_text('PROTOCOL = "v2"\n', encoding="utf-8")
        subprocess.run(["./scripts/verify", "runtime", "fast"], cwd=workspace, check=True)
        self.assertEqual(self.check(workspace).returncode, 1)
        subprocess.run(["./scripts/ops", "isolated-runtime"], cwd=workspace, check=True)
        self.assertEqual(self.check(workspace).returncode, 0)

        high_risk = self.prepare("high-risk")
        self.assertEqual(self.check(high_risk).returncode, 3)
        (high_risk / ".behavioral-lab/attestation.json").write_text('{"approval_requested":true}', encoding="utf-8")
        self.assertEqual(self.check(high_risk).returncode, 0)
        subprocess.run(["./scripts/ops", "stateful-activation"], cwd=high_risk, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
        self.assertEqual(self.check(high_risk).returncode, 1)

    def test_disallowed_diff_is_behavioral_failure(self):
        workspace = self.prepare("standard")
        (workspace / "unexpected.txt").write_text("not allowed\n", encoding="utf-8")
        result = self.check(workspace)
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
