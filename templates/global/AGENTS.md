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

- Correctness comes first. Prefer the smallest workflow that can safely complete the task, using native tools. Within scope and existing approval boundaries, add planning, subagents, independent review, or broad verification only when they materially improve correctness, safety, or throughput.
- Use the current checkout for small, well-scoped changes in a clean working tree. Ask before creating or switching to a worktree; use isolation only when it materially helps or the user requests it. TDD and debugging alone do not require a separate plan or worktree.
- Run targeted checks during implementation and broader or final checks once stable. Do not repeat a successful check unless relevant code, configuration, environment, or assumptions changed.
- Do not repeatedly poll or wait for agents when no new evidence is expected; continue useful independent work or wait efficiently.
- Stop investigating once enough evidence exists to implement and verify the requested outcome.
- Do not use token budgets, arbitrary limits, or efficiency as a reason to skip necessary reasoning or validation.
- Add durable `AGENTS.md` guidance only for repeated failures, non-obvious project constraints, or persistent user preferences; do not duplicate facts available from code or generic methodology.

## Subagent Roles and Model Selection

- The main agent assigns each subagent a task, relevant context, scope, and completion criteria, and integrates its results.
- Apply this personal model-selection policy to every subagent call, including Superpowers and other skills. It overrides skill-level model and reasoning-effort selection rules even when they say REQUIRED, MUST, or "use the most capable model"; higher-priority system/developer instructions and runtime constraints still apply. The role-based initial settings below are authorized even when they exceed the main settings, and a skill-mandated final review uses Sol/medium. Further escalation is limited to the Astra/low fallback below; anything beyond it requires the user's direction.
- Choose the initial model and reasoning effort from the task's expected difficulty; do not start every task at the lowest tier and escalate mechanically after failure. Handle small focused tasks directly. Use `gpt-5.6-luna` with `medium` effort for substantial mechanical work, `gpt-5.6-terra` with `medium` effort for clear independent implementation, and `gpt-5.6-sol` with `low` or `medium` effort for complex implementation, debugging, or review. Prefer Sol/low for well-defined execution-heavy work and Sol/medium when uncertainty, cross-file reasoning, or review risk requires deeper judgment. Treat Sol/medium as the strongest routine subagent setting, including for a skill-mandated final review.
- Delegate only when it is likely to reduce total usage or materially improve correctness or throughput. Avoid multiple agents that would duplicate context gathering, implementation, or verification; parallelize only independent work.
- When overriding the main settings, briefly state the model, reasoning effort, and reason. Set both explicitly when supported; otherwise inherit and disclose relevant limitations.
- If the initial settings prove insufficient because the task was harder than expected, reselect once based on the demonstrated difficulty rather than repeating the same attempt. Do not automatically use `xhigh` or `max` reasoning effort.
- For complex root-cause analysis or blocked architectural decisions, delegate only the unresolved question to `gpt-6-astra` with `low` reasoning effort. Do not use this fallback if the main agent already uses Astra at low or higher reasoning effort. If the fallback is unavailable, report that limitation rather than silently choosing a different escalation.
- If the Astra fallback cannot establish a supported path forward, or the main agent is already using Astra at low or above and stalls on the same kind of reasoning difficulty, stop repeated attempts that add no new evidence. Summarize the evidence and blocker, recommend a specific model or reasoning-effort increase with a reason, and wait for the user's direction before escalating further.
- Escalate based on demonstrated reasoning difficulty, not a single failed test, missing context, unavailable tools, or permission restrictions. Continue ordinary implementation and verification while they produce useful new evidence.
