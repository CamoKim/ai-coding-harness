import os, shutil, subprocess, tempfile, unittest
from pathlib import Path

ROOT = Path(__file__).parents[1]
DOCTOR = ROOT / "scripts" / "doctor"

@unittest.skipIf(os.environ.get("HARNESS_DOCTOR_RUNNING") == "1", "avoid doctor validation recursion")
class DoctorTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(); self.home = Path(self.temp.name)
        self.env = {**os.environ, "HOME": str(self.home), "PYTHONDONTWRITEBYTECODE": "1"}
        codex = self.home / ".codex"; (codex / "harness/bin").mkdir(parents=True)
        shutil.copyfile(ROOT / "templates/global/AGENTS.md", codex / "AGENTS.md")
        shutil.copyfile(ROOT / "scripts/telemetry-record", codex / "harness/bin/telemetry-record")
        shutil.copyfile(ROOT / "templates/telemetry/hooks.json", codex / "hooks.json")
    def tearDown(self): self.temp.cleanup()
    def invoke(self, *args): return subprocess.run([str(DOCTOR), *args], env=self.env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=False)
    def test_reports_parity_and_observations(self):
        result = self.invoke()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('global-parity\tOK', result.stdout); self.assertIn('telemetry-opt-in\tDISABLED', result.stdout); self.assertIn('SUMMARY\tOK', result.stdout)
    def test_argument_and_inline_hook_conflict(self):
        self.assertEqual(self.invoke('unexpected').returncode, 64)
        (self.home / '.codex/config.toml').write_text('[hooks]\n', encoding='utf-8')
        result = self.invoke()
        self.assertEqual(result.returncode, 1); self.assertIn('hooks-config\tCONFLICT', result.stdout)

    def test_features_and_hook_state_are_not_inline_hook_conflicts(self):
        (self.home / '.codex/config.toml').write_text(
            '[features]\nhooks = true\n\n[hooks.state]\n', encoding='utf-8'
        )
        result = self.invoke()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('hooks-config\tOK', result.stdout)

    def test_complete_uninstall_is_a_normal_observation(self):
        shutil.rmtree(self.home / '.codex')
        result = self.invoke()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('global-parity\tNOT_INSTALLED', result.stdout)
        self.assertIn('SUMMARY\tOK', result.stdout)

if __name__ == '__main__': unittest.main()
