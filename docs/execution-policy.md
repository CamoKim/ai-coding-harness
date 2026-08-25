# Execution Policy

## Purpose

This policy decides how deeply Codex should investigate, plan, verify, and seek direction for a request. It applies before choosing a project-owned command or workflow; it does not replace repository architecture, compatibility, verification, or operational contracts.

Classify each task as exactly one of: `TRIVIAL`, `STANDARD`, `COMPLEX`, or `HIGH-RISK`. Start with the lowest level justified by known facts and raise the level when scope, compatibility, state, security, or runtime impact requires it.

## Task Levels

| Level | Investigation and plan | Change autonomy | Verification and runtime evidence | Delegation or independent review | Ask or obtain approval |
| --- | --- | --- | --- | --- | --- |
| `TRIVIAL` | Inspect the directly relevant files and execution path. No plan is required. | Make a clearly reversible, ordinary change within the request. | Run the smallest relevant available check; do not claim broader coverage. Runtime E2E is normally unnecessary. | Do not require either. | Ask only when the target, authority, or material effect cannot be established from the repository or tools. |
| `STANDARD` | Inspect the relevant subsystem, contracts, and tests. Use a brief plan only when sequencing materially helps. | Make ordinary reversible implementation choices within the clear request. | Run relevant project checks, normally the affected fast verification. Consider runtime E2E only for externally observable integration behavior when safe project-owned evidence exists. | Consider only when a genuinely independent task or a meaningful review risk exists; never as routine ceremony. | Ask when product intent can reasonably lead to different outcomes, or a compatibility/public-contract choice is needed. |
| `COMPLEX` | Trace affected execution paths, consumers, contracts, and verification boundaries. Write a brief plan before editing. | Proceed autonomously only while the requested outcome and compatibility choice are clear; keep changes coherent and scoped. | Run affected fast checks and required cross-subsystem or full checks when the project contract calls for them. Consider runtime E2E for integration, workflow, or runtime-path changes; do not run stateful evidence without authorization. | Consider a subagent or independent review only for workstreams that are actually independent, or for a material defect/compatibility risk. | Ask before choosing between materially different product outcomes, changing a public/compatibility contract, or expanding scope beyond the request. |
| `HIGH-RISK` | Establish the source of truth, affected consumers, operational target, rollback or isolation conditions, and required authority. Write a brief plan before editing. | Do not change production or shared state, perform destructive work, cross a credential/security boundary, or make an unresolved compatibility choice without explicit approval. A specifically requested, reversible code change may proceed only after those boundaries are resolved. | Run all safe required checks. Runtime E2E needs explicit authorization whenever it can affect shared state, credentials, external systems, or persistent data. | Consider independent review for material security, compatibility, operational, or irreversible consequences; use subagents only for independent work. | Explicit approval is required for production/shared-state mutation, destructive operations, credential or security-boundary changes, and compatibility/public-contract choices. |

## Autonomy Rules

- Resolve questions that repository inspection or available tools can answer; do not ask the user first.
- Verify facts with available tests or checks before relying on them.
- Continue through reversible ordinary code changes without unnecessary checkpoints.
- Choose implementation details autonomously when they remain inside a clear requested outcome.
- Ask when product intent has materially different valid directions, or when a compatibility or public-contract decision is required.
- Do not change production or shared state, perform destructive work, or cross credential or security boundaries without explicit approval.
- Do not require brainstorming, detailed planning, subagents, or independent review for small work.
- Consider subagents only for genuinely independent workstreams; they are never a substitute for resolving dependencies or reviewing evidence.

## Verification Boundary

Select verification scope, level, and runtime evidence from changed files, affected dependencies and contracts, and the repository's Verification Routing rules. The repository's verification contract defines commands, prerequisites, mutation limits, and result meanings. An unavailable required environment remains unsupported rather than successful. Runtime E2E is evidence to consider when the changed behavior requires it, not a default requirement; stateful evidence still needs the required explicit approval.

## Project Overrides

A repository may add stricter rules in its repository `AGENTS.md` for:

- work it additionally treats as `HIGH-RISK`;
- mandatory verification or runtime evidence for defined changes;
- autonomous-operation allowlists or deny lists.

Project overrides must name the affected work and may strengthen, but not weaken, this policy's approval and safety boundaries. Put subsystem-specific detail in the nearest subsystem instruction only when it differs from the repository rule.

## Optional Methodology Providers

This policy does not require Superpowers or any other skill bundle. If Superpowers is installed, its planning, TDD, debugging, review, and collaboration workflows may be used as optional methodology. The Harness does not duplicate those workflows or make E1 behavior depend on their availability.
