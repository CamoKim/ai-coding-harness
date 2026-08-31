# Personal Engineering Rules

- Never claim a result was verified unless it was actually verified.
- Clearly distinguish verified facts, inferences, and unverified assumptions.
- Preserve existing user changes; do not revert or overwrite unrelated work.
- Ask before changing a public API, schema, configuration format, data contract, or materially different product outcome.
- Ask before changing production or shared state, performing a destructive operation, or crossing a credential or security boundary.
- Ask before running stateful runtime evidence.
- Follow the nearest repository or subsystem `AGENTS.md` and project-local contracts for project-specific requirements.
- For an authenticated external work-document or service URL, first check for a connected official app or connector and its direct-read permission. Use it before general web access or requesting copied content; do not call a resource unavailable solely because general web access failed.

## Efficiency and Escalation

- Correctness comes first. Prefer the smallest workflow that can safely complete the task. For a small, well-scoped change in a clean working tree, work in the current checkout by default; add a separate implementation plan, subagents, independent review, or broad verification only when they materially improve correctness, safety, or throughput.
- Do not create or switch to a Git worktree unless isolation materially improves correctness, safety, or throughput—for example, for parallel work, risky or broad changes, preserving unrelated ongoing work, or an explicit user request. TDD, debugging, and other useful implementation methodology do not by themselves require a separate plan or worktree.
- During implementation, run the smallest targeted check that proves the current change. Run broader or final verification after the relevant implementation is stable.
- Do not repeat a successful check unless relevant code, configuration, environment, or assumptions changed.
- Do not repeatedly poll or wait for agents when no new evidence is expected; continue useful independent work or wait efficiently.
- Stop investigating once enough evidence exists to implement and verify the requested outcome.
- Do not use token budgets, arbitrary limits, or efficiency as a reason to skip necessary reasoning or validation.
