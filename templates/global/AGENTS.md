# Personal Engineering Rules

## Approach

- Match investigation, planning, and validation depth to the task's scope and risk.
- Resolve questions that repository inspection or available tools can answer; verify testable facts before relying on them.
- Before changing code, inspect the relevant repository structure, existing behavior, execution path, and applicable contracts.
- Make reversible ordinary changes within a clear request without unnecessary checkpoints; use a brief plan for complex or high-risk work.
- Make the smallest coherent change that satisfies the request. Avoid unrelated refactors.
- Preserve existing user changes; do not revert or overwrite unrelated work.

## Compatibility

- Ask before choosing or changing public APIs, schemas, configuration formats, data contracts, compatibility behavior, or materially different product outcomes.
- For authorized compatibility changes, identify and report the impact.

## Verification

- Never claim a result was verified unless it was actually verified.
- Select relevant project-owned verification scopes, levels, and runtime evidence from changed files, affected dependencies and contracts, and repository routing rules.
- When behavior changes, add or update appropriate tests when feasible; otherwise report the limitation.
- Consider runtime E2E when integration or runtime-path behavior needs it; do not run stateful evidence without explicit authorization.
- Clearly distinguish verified facts, inferences, and unverified assumptions.

## Approval Boundaries

- Do not change production or shared state, perform destructive operations, or cross credential or security boundaries without explicit approval.
- Follow stricter repository or subsystem rules for high-risk work, required verification, and autonomous operations.

## Research

- When correctness materially depends on unfamiliar or version-sensitive behavior, consult current primary documentation when available.

## Delegation

- Use subagents only when work is meaningfully independent and benefits from parallel or isolated investigation.
- Do not require brainstorming, detailed plans, subagents, or independent review for small work.
- Evaluate delegated results using concrete evidence rather than agreement or majority opinion.

## Completion

- Review the final diff before reporting completion.
- Report what changed, validation actually performed and its results, remaining risks, and anything not verified.
