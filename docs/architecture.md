# Personal AI Coding Harness Architecture

## Purpose

Personal AI Coding Harness v0.2 provides a small, reusable foundation for working with Codex across repositories. It standardizes durable instructions, task-depth and autonomy boundaries, and the interface used to invoke project-owned verification without centralizing project knowledge.

The goal is a feedback-driven harness: begin with a minimal contract, use it in real projects, and promote only repeated, proven practices into shared artifacts.

## Ownership Boundary

The Harness owns:

- stable personal engineering rules;
- generic repository and subsystem instruction templates;
- the execution-policy contract for task depth and user-direction boundaries;
- the verification interface and dispatcher pattern;
- the optional local efficiency-telemetry contract and its data-minimization boundary;
- contracts for installing and applying Harness artifacts;
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

    docs/execution-policy.md
        → task classification and autonomy decisions

    docs/telemetry-contract.md
        → optional local task metrics outside repositories

    templates/verification/*
        → project-owned verification scripts

Project feedback
        → reviewed improvements to Harness contracts and templates
```

The Global template is already applied manually. Project bootstrap and managed Global installation are contracts for later implementation; Build Batch 1 does not provide an installer or modify adopted projects.

## Verification Architecture

The repository-level verifier dispatches a requested scope and level. It does not contain build or test commands. A subsystem verifier owns the actual recipe for its subsystem and follows the shared exit-code and reporting contract.

This separation gives Codex one predictable entry point while allowing subsystems with different stacks and risk profiles to validate themselves correctly.

## Planned Extensions

The following are planned, not implemented in Build Batch 1:

- reusable Skills for verification, review, and technology research;
- custom explorer, researcher, and reviewer agents;
- opt-in, deterministic Hooks after their value is demonstrated;
- CI that invokes stable project-owned verification commands;
- MCP integrations when external data or actions become necessary.

Skills will package repeatable workflows. Custom Agents will isolate genuinely independent roles. Hooks and CI will enforce only contracts that have first proven reliable through local use.

The execution policy does not require a skill bundle. Optional methodology providers such as Superpowers may supply planning, TDD, debugging, review, or collaboration workflows, while the Harness retains responsibility only for task depth and autonomy boundaries.
