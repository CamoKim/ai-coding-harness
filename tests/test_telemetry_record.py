import json, os, subprocess, tempfile, unittest
from pathlib import Path
ROOT = Path(__file__).parents[1]; HANDLER = ROOT / "scripts" / "telemetry-record"
class TestTelemetryHooks(unittest.TestCase):
 def setUp(self): self.temp=tempfile.TemporaryDirectory(); self.home=Path(self.temp.name); self.env={**os.environ,"HOME":str(self.home)}
 def tearDown(self): self.temp.cleanup()
 def hook(self,event): return subprocess.run([str(HANDLER)],input=json.dumps(event).encode(),stdout=subprocess.PIPE,stderr=subprocess.PIPE,env=self.env,check=False)
 def event(self,name): return {"hook_event_name":name,"turn_id":"turn-private-test","model":"gpt-5.6-terra","prompt":"never persist","transcript_path":"/private/transcript","tool_input":{"command":"secret"},"last_assistant_message":"never persist"}
 def enable(self):
  root=self.home/".codex/harness/telemetry"; root.mkdir(parents=True); (root/"enabled").write_bytes(b"enabled\n"); return root
 def test_opt_out_creates_no_state(self): self.assertEqual(self.hook(self.event("UserPromptSubmit")).returncode,0); self.assertFalse((self.home/".codex").exists())
 def test_full_hook_lifecycle_creates_exactly_one_turn_record(self):
  root=self.enable()
  for name in ("UserPromptSubmit","PermissionRequest","SubagentStart","Stop","Stop"): self.assertEqual(self.hook(self.event(name)).returncode,0)
  lines=(root/"turns.jsonl").read_text().splitlines(); self.assertEqual(len(lines),1); record=json.loads(lines[0])
  self.assertEqual(record["record_unit"],"turn"); self.assertEqual(record["model"],"gpt-5.6-terra"); self.assertEqual(record["approval_request_count"],1); self.assertEqual(record["subagent_count"],1); self.assertIsNone(record["reasoning_effort"])
  self.assertNotIn("never persist",lines[0]); self.assertNotIn("/private",lines[0]); self.assertNotIn("secret",lines[0])
if __name__ == "__main__": unittest.main()
