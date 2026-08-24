# Personal Engineering Rules

## Approach

- Match the depth of investigation, planning, and validation to the task's scope and risk.
- Before changing code, inspect the relevant repository structure, existing behavior, and execution path.
- For non-trivial or high-risk changes, outline a brief plan and resolve material unknowns before editing.
- Make the smallest coherent change that satisfies the request. Avoid unrelated refactors.
- Preserve existing user changes; do not revert or overwrite unrelated work.

## Compatibility

- Do not change public APIs, schemas, configuration formats, data contracts, or compatibility behavior without explicit authorization.
- For authorized compatibility changes, identify and report the impact.

## Verification

- Never claim a result was verified unless it was actually verified.
- Run relevant available checks in proportion to the changed behavior and risk.
- When behavior changes, add or update appropriate tests when feasible; otherwise report the limitation.
- Clearly distinguish verified facts, inferences, and unverified assumptions.

## Research

- When correctness materially depends on unfamiliar or version-sensitive behavior, consult current primary documentation when available.

## Delegation

- Use subagents only when work is meaningfully independent and benefits from parallel or isolated investigation.
- Evaluate delegated results using concrete evidence rather than agreement or majority opinion.

## Completion

- Review the final diff before reporting completion.
- Report what changed, validation actually performed and its results, remaining risks, and anything not verified.
