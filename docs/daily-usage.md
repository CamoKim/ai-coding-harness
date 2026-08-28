# Daily Codex Usage

The long-term interface is short, natural-language requests. The Harness supplies the project facts that let Codex select safe work and verification; it is not a workflow command layer.

## Everyday Requests

Use a normal Codex request for ordinary scoped work: “Explain this failure,” “Add an audit field to the invoice API and verify affected consumers,” or “Review this diff for compatibility risks.” Native Codex handles reasoning, tools, approvals, and sessions. Superpowers methodology is applied implicitly when it helps; you do not need to manually invoke planning, TDD, debugging, or review machinery for routine work.

Ask for a specific outcome and relevant constraints. The nearest `AGENTS.md` and the project’s Verification Routing rules provide the project context. For work that might change a public contract, shared or production state, credentials, or a security boundary, expect Codex to ask before crossing it.

## Native Codex Capabilities

| Use this when | It gives you | Command or prompt |
| --- | --- | --- |
| Work spans multiple turns or should survive a pause | a persistent objective and resume point | `/goal <outcome>`; later `/goal resume` |
| Independent investigation or implementation can proceed in parallel | native subagents with separate bounded tasks | “Use native subagents to inspect the API and UI impact in parallel.” |
| You need isolated changes or parallel branches | Git worktrees managed through native Codex and Git | “Create a worktree for this feature before editing.” |
| You want an independent quality pass | Codex review against risks, requirements, or a diff | “Review this diff for bugs and contract regressions.” |
| A task is scripted, repeatable, or should run non-interactively | a Codex execution session | `codex exec '<clear task and constraints>'` |
| You need a local automation trigger | native hooks, scoped to a concrete project need | “Add a hook that runs the project’s fast verification after this command.” |
| You need evidence for the changed area | the project-owned verification contract | `./scripts/verify <affected-scope> fast`; use `full` when routing requires it |

Use `/goal` for a coherent outcome, not every one-line request. Use subagents, worktrees, and review only when they materially improve correctness, safety, or throughput; a single focused task is normally clearer in one Codex session. Use a worktree when changes need isolation, and ask for review before merging consequential work.

`codex exec` and hooks are native tooling, not Harness replacements for project build systems. Keep hooks small, local, and transparent. Do not use hooks to conceal stateful work, secret handling, or production actions.

## Project Verification

After a change, ask Codex to identify affected scopes and run the project verifier, or run it directly when the scope is known:

```text
./scripts/verify <scope> fast
./scripts/verify <scope> full
```

`fast` does not claim `full` coverage. If runtime evidence is stateful, the repository instructions must name it and Codex must request approval before running it. Setup, dependency installation, migrations, deploys, and other mutations are separate from verification.

## Optional OMX

Use OMX only when durable, team-oriented orchestration materially improves the work: for example, coordinated handoffs among multiple people or agents, a long-running external workflow, or persistent operational tracking. For ordinary single-user coding tasks, use Native Codex, Superpowers methodology, Git, and the project verifier directly. The Harness does not install, configure, or operate OMX.
