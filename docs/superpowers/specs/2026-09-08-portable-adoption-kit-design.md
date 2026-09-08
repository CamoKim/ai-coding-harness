# Portable Adoption Kit Design

## Goal

Make the Harness usable by another person without private setup knowledge or
interpretation of scattered documents. A user should be able to decide whether
the Harness fits a target repository, merge only the relevant templates, add a
minimal project-owned verification contract, and verify the completed adoption.

## Scope and Boundary

The kit is a portable, manual-adoption package. It does not install Codex,
plugins, Graphify, accounts, credentials, connectors, local trust, or user
services. It does not overwrite an existing `AGENTS.md`, create project build
commands, or configure a repository graph automatically.

Those omissions are deliberate. They preserve the current owner's project
facts and keep machine-specific or credential-bearing state outside a portable
Git repository. Fully reproducing a machine belongs to a later, separate
environment-reproduction capability.

## Components

| Component | Responsibility |
| --- | --- |
| `docs/portable-adoption-kit.md` | One external-user path: suitability, prerequisites, merge order, completion checks, rollback, optional Graphify, and update policy. |
| `README.md` | Exposes the kit as the entry point for people adopting the Harness in another repository. |
| `scripts/validate` | Requires the kit document so a later edit cannot silently remove the external adoption path. |
| Existing templates and guides | Remain the source for actual template content, detailed adoption principles, daily usage, configuration ownership, and verification contract. |

## User Flow

```text
Read Portable Adoption Kit
    ↓
Confirm the target repository is safe for manual instruction merging
    ↓
Read existing project instructions and documentation
    ↓
Merge global template, then repository template, then only needed subsystem template
    ↓
Define or document project-owned ./scripts/verify <scope> <level>
    ↓
Run the target project's safe verification and inspect the diff
    ↓
Optionally add Graphify using its project-scoped pattern
    ↓
Commit only reviewed project-owned changes
```

The kit points to existing detailed documents rather than duplicating their
contents. A user can stop after any step without leaving a partially managed
global configuration or a hidden background process.

## Safety and Failure Handling

- If the target repository has existing instructions, merge rather than replace
  them. Resolve conflicts with the project owner or its sources of truth.
- If a project cannot truthfully supply a verifier, record that limitation and
  do not invent a generic build command.
- If safe verification fails, repair or revert the target project change; do
  not alter the Harness templates to conceal the failure.
- If local prerequisites are missing, use their official setup paths and keep
  resulting local state out of the Harness repository.
- If Graphify is not useful for the target repository, do not install it. If
  it is useful, keep the skill, graph artifacts, and watcher project-scoped.

## Verification

The Harness validation must pass with the kit present and fail when the kit is
removed from an otherwise equivalent copy. The kit must contain no machine
paths, usernames, credentials, or project-specific commands. Manual review
checks that every linked template or guide already exists and that the stated
flow preserves the ownership boundaries in the reference environment.

## Success Criteria

Another person can clone the repository, follow one linked document to adopt
the reusable instruction and verification pattern in a compatible repository,
and know both what was deliberately not installed and how to safely undo the
adoption. This achieves portable reuse; exact reproduction of a personal
machine remains out of scope.
