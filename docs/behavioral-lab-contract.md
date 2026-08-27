# Behavioral Lab Contract

The Behavioral Lab is a manual or semi-automated regression fixture for verification routing and approval evidence. It never launches Codex, changes model/profile/telemetry settings, or accesses external, production, shared, credentialed, network, database, or container state.

`./scripts/behavioral-lab prepare <scenario>` copies the seed repository to an isolated temporary workspace and prints its prompt path. `./scripts/behavioral-lab check <workspace>` is read-only: it compares the workspace with its prepared baseline and reads fixture-local evidence only.

Behavioral pass requires an allowed diff, required fixture audit events, no forbidden event, and any required manual JSON attestation. It never matches natural-language responses. Audit JSONL events are fixed small objects: `{"event":"verify","scope":"<scope>","level":"fast"}`, `{"event":"runtime","mode":"isolated"}`, or `{"event":"stateful-sentinel","action":"activation"}`.

Exit `0` means evidence passed, `1` behavioral evidence failed, `2` fixture/schema/workspace/audit error, `3` required manual attestation is absent or incomplete, and `64` means invalid invocation. Fixture audit state remains inside the temporary workspace; it is not Harness telemetry. Run real Codex only manually or in a separately isolated profile with no telemetry marker or hooks, so synthetic turns cannot enter E4 records.
