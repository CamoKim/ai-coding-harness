# Portable Adoption Kit

## Is This a Fit?

Use this kit for an existing Git repository whose owner can review instruction changes and identify safe verification. Do not use it to blindly modify an unknown repository, a production-only checkout without safe verification, or a repository you do not own or cannot review. Read the target repository's `AGENTS.md` files and source-of-truth documentation first.

## What You Will and Will Not Get

You get reusable engineering-rule and `AGENTS.md` templates, a project-owned verification-contract pattern, and documentation explaining their boundaries. You keep control of project facts, build commands, and local environment.

This kit does not install or configure Codex, accounts, plugins, credentials, connectors, trust decisions, Graphify, or user services. It does not replace an existing `AGENTS.md`, infer build commands, or make a repository graph mandatory. Those remain intentionally owned by the user, project, or opted-in project tool.

## Safe Adoption Path

1. Read existing instructions and source-of-truth documentation. Identify who or what can confirm architecture, contracts, and safe verification.
2. Carefully merge [`templates/global/AGENTS.md`](../templates/global/AGENTS.md) into normal global Codex guidance. Preserve unrelated personal rules.
3. Carefully merge [`templates/repository/AGENTS.md`](../templates/repository/AGENTS.md) into `<repository>/AGENTS.md`. Replace bracketed prompts only with verified facts.
4. Add [`templates/subsystem/AGENTS.md`](../templates/subsystem/AGENTS.md) only where a subtree has distinct architecture, execution, compatibility, or safety facts.
5. Review the resulting diff with the repository owner or sources of truth. Preserve useful existing instructions; reconcile conflicts instead of replacing whole files.
6. Run safe project verification, then commit only reviewed project-owned changes.

For full merge rules and instruction hierarchy, use the [adoption workflow](adoption.md). The templates provide structure; the target repository supplies true facts.

## Define the Project Verification Contract

Where useful, give the target repository one documented entry point:

```text
./scripts/verify <scope> <level>
```

The repository chooses scopes and maps them to existing test, lint, typecheck, or integration commands. `fast` is low-cost evidence for an affected scope; `full` adds meaningful higher-cost evidence. Do not invent a generic command, conceal a missing environment, install dependencies, migrate data, deploy, or run stateful work as default verification.

Document an unavailable environment honestly and use exit code `2` when appropriate. See the [verification contract](verification-contract.md) and [repository template](../templates/repository/AGENTS.md) for the full interface and routing guidance.

## Optional Graphify Path

Add Graphify only for a distinct need for broad or cross-cutting structural exploration. Focused work does not need it. If you opt in, follow the [Graphify design](superpowers/specs/2026-09-07-graphify-adoption-design.md) and [adoption plan](superpowers/plans/2026-09-07-graphify-adoption.md).

Install the CLI at user scope, but keep Codex guidance, generated graph artifacts, and watcher scoped to each adopted repository. Commit shared graph outputs and ignore machine-local cache, path markers, cost, manifest, and pending-semantic state. Do not install Graphify Git hooks. Graphify is navigation evidence, not a substitute for source inspection, compatibility review, or project verification.

## Completion Checklist

- Existing global and project instructions were merged rather than overwritten.
- New repository `AGENTS.md` statements are verified, durable, and narrow.
- The repository has a documented verification route and honest environment limits.
- Safe verification produced evidence appropriate to the adopted instructions.
- The reviewed diff has no local paths, usernames, credentials, tokens, or account-specific configuration.
- Graphify, if adopted, is project-scoped and has a distinct use case.
- The project owner knows how to update or remove adopted hunks.

## Undo or Update an Adoption

Before undoing an adoption, inspect later project changes that may depend on the adopted instructions or verification route. Revert only exact adopted hunks after that review; never delete an entire existing `AGENTS.md` by default.

For an update, compare the current Harness template with target-repository facts and merge only changes that remain true and useful. Use [the reference environment](reference-environment.md) to choose the narrowest owner for recurring issues and [the re-entry guide](returning-to-the-harness.md) after a long pause or machine change.

## When to Stop and Ask

Stop and ask the relevant project owner before changing a public API, schema, configuration format, data contract, production or shared state, credentials, or a security boundary. Also stop when an instruction conflict cannot be resolved from project sources, a verifier needs stateful action, or a local prerequisite is unavailable.

The safe outcome is a documented limitation or deferred adoption step—not an invented command, hidden local setting, or overwritten project rule.
