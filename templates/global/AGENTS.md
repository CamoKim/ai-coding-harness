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
- For in-scope work, choose the smallest native workflow that materially improves correctness, safety, or throughput. You may autonomously use planning, subagents, independent review, and non-destructive verification. Before creating or switching to a Git worktree, ask first. Existing approval boundaries remain unchanged.
- During implementation, run the smallest targeted check that proves the current change. Run broader or final verification after the relevant implementation is stable.
- Do not repeat a successful check unless relevant code, configuration, environment, or assumptions changed.
- Do not repeatedly poll or wait for agents when no new evidence is expected; continue useful independent work or wait efficiently.
- Stop investigating once enough evidence exists to implement and verify the requested outcome.
- Do not use token budgets, arbitrary limits, or efficiency as a reason to skip necessary reasoning or validation.

## Subagent Roles and Model Selection

- The main agent assigns each subagent a concrete task, relevant context, scope, and completion criteria, and integrates its results. Handle simple tasks directly when delegation would add unnecessary overhead.
- Apply this personal model-selection policy to every subagent call, including Superpowers and other skills. It overrides skill-level model and reasoning-effort selection rules even when they say REQUIRED, MUST, or "use the most capable model"; higher-priority system/developer instructions and runtime constraints still apply. A skill-mandated review does not itself authorize a model upgrade: perform a routine final review with the default or justified reduced settings. Automatic escalation beyond the main settings is limited to the Astra/low fallback below; any further escalation requires the user's direction.
- Use the main agent's model and reasoning effort as the default. Choose a less capable model or lower reasoning effort from the currently available options only when the task is clear and bounded enough that doing so is likely to reduce total usage without increasing retries, rework, or review burden. When uncertain, retain the default.
- Judge efficiency by the total effort needed to reach a verified result, not by the cost of an individual call. When selecting settings different from the main agent's, briefly state the selected model, reasoning effort, and reason. Explicitly set both in the call when the tool supports overrides; otherwise use inheritance and disclose any relevant limitation.
- If reduced settings prove insufficient because of task difficulty, return to the main agent's settings rather than repeatedly retrying below them.
- For complex root-cause analysis or blocked architectural decisions, delegate only the unresolved question to `gpt-6-astra` with `low` reasoning effort. Do not use this fallback if the main agent already uses Astra at low or higher reasoning effort. If the fallback is unavailable, report that limitation rather than silently choosing a different escalation.
- If the Astra fallback cannot establish a supported path forward, or the main agent is already using Astra at low or above and stalls on the same kind of reasoning difficulty, stop repeated attempts that add no new evidence. Summarize the evidence and blocker, recommend a specific model or reasoning-effort increase with a reason, and wait for the user's direction before escalating further.
- Escalate based on demonstrated reasoning difficulty, not a single failed test, missing context, unavailable tools, or permission restrictions. Continue ordinary implementation and verification while they produce useful new evidence.
