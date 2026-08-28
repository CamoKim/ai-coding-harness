# Personal AI Coding Harness Architecture

## Purpose

Personal AI Coding Harness v0.3 provides a small, reusable foundation for working with Codex across repositories. It standardizes durable safety instructions and the interface used to invoke project-owned verification without centralizing project knowledge.

The goal is a feedback-driven harness: begin with a minimal contract, use it in real projects, and promote only repeated, proven practices into shared artifacts.

## Ownership Boundary

| Owner | Owns | Does not own here |
| --- | --- | --- |
| Native Codex | reasoning, execution, tools, approvals, sessions, `/goal`, subagents, review capability, `codex exec`, hooks, and native capabilities | project-specific facts and verification recipes |
| Superpowers | generic engineering methodology: brainstorming, planning, TDD, debugging, review methodology, and verification discipline | duplicate Harness instructions or project knowledge |
| This Harness | project-specific facts, architecture, constraints, safety boundaries, instruction hierarchy, and verification contracts | generic methodology, native Codex features, or runtime orchestration |
| OMX (optional) | durable or team orchestration when it materially helps | the normal single-user coding workflow |

The Harness must not duplicate generic Superpowers methodology. A project records the local facts that let Codex and Superpowers apply their own capabilities correctly.

The Harness owns:

- stable personal engineering rules;
- generic repository and subsystem instruction templates;
- minimal personal safety instructions that defer generic engineering methodology to Native Codex and Superpowers;
- the optional verification interface contract;
- validation of the Harness repository itself.

Each adopted project owns:

- its architecture, dependencies, and execution paths;
- its build, test, lint, and other validation commands;
- its subsystem-specific risks and compatibility contracts;
- its changed-file, dependency, and contract routing map for verification;
- the implementation and maintenance of its verification recipes.

Project commands must not be copied into this repository. This keeps operational knowledge close to the code it governs and avoids drift between Harness templates and project reality.

## Instruction Hierarchy

```text
Global ~/.codex/AGENTS.md
    ↓
Repository AGENTS.md
    ↓
Subsystem AGENTS.md
    ↓
Narrow directory AGENTS.md, only when needed
```

- **Global** instructions define personal working, verification, compatibility, and reporting principles that apply across repositories.
- **Repository** instructions map a repository, identify shared dependencies and contracts, and route work to its subsystems.
- **Subsystem** instructions describe local execution paths, architecture constraints, commands, risks, and verification.
- **Directory** instructions are reserved for a subtree with genuinely distinct rules, such as generated artifacts or schema sources of truth.

Each layer adds only information specific to its scope. Lower layers do not repeat the Global rules.

## Artifact Flow

```text
Harness source of truth
    templates/global/AGENTS.md
        → ~/.codex/AGENTS.md

    templates/repository/AGENTS.md
        → <repository>/AGENTS.md (including verification routing)

    templates/subsystem/AGENTS.md
        → <repository>/<subsystem>/AGENTS.md

Project feedback
        → reviewed improvements to Harness contracts and templates
```

The Global template is a normal user-level file. The Harness does not manage its installation, provenance, or lifecycle.

## Verification Architecture

When a project provides `./scripts/verify <scope> <level>`, that project-owned command dispatches or runs the requested verification. Its implementation and verification recipes remain with the project and follow the shared exit-code and reporting contract.

Where a project defines that entry point, it gives Codex a predictable command while allowing subsystems with different stacks and risk profiles to validate themselves correctly.

## Optional OMX

Use OMX only when work needs durable coordination across people, agents, or a long-running runtime. Normal repository work, task planning, implementation, verification, and review remain in Native Codex with the project’s own instructions and verifier.

## Planned Extensions

The following remain planned, not implemented in v0.3:

- CI that invokes stable project-owned verification commands;
- MCP integrations when external data or actions become necessary.

Native Codex and optional methodology providers such as Superpowers supply generic engineering workflows. The Harness keeps only project-local contracts that require reusable expression.
