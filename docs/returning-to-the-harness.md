# Returning to the Harness

Use this guide after a long pause, a machine change, or when the reason for an
existing Harness choice is no longer clear. Its purpose is to restore the
working model before changing configuration or copying templates.

## Five-Minute Re-entry

From the Harness repository, run the two read-only checks below:

```text
git status --short --branch
./scripts/validate
```

Read [the reference environment](reference-environment.md) next. It states the
baseline, ownership boundary, optional Graphify role, deliberate exclusions,
and reproducibility limit. Then use the route that matches the work at hand:

| Situation | Start here | Do not do |
| --- | --- | --- |
| Ordinary work in an already adopted repository | Open Codex in that repository and make a normal outcome-focused request. | Do not invoke a Harness wrapper or copy generic rules into the project again. |
| A new repository needs the environment | Follow the [adoption guide](adoption.md), merging templates with existing project instructions. | Do not overwrite an existing `AGENTS.md` or assume its build commands. |
| Broad or cross-cutting work in a Graphify-enabled repository | Use the repository's Graphify guidance and current graph as navigation evidence. | Do not treat graph output as proof or replace the repository verifier. |
| A project needs a repository graph for the first time | Follow the project-scoped Graphify pattern in the [adoption plan](superpowers/plans/2026-09-07-graphify-adoption.md). | Do not register Graphify guidance globally or install Git hooks. |
| A local Codex, plugin, account, or service-manager setting is absent | Re-establish that user-owned prerequisite deliberately, then return here. | Do not add local paths, credentials, or account state to the Harness repository. |

If `./scripts/validate` fails, fix the Harness source contract before treating
the templates as a reliable baseline. If the target repository's own verifier
fails, investigate it in that repository; the Harness does not own its build
or runtime state.

## Mental Model to Restore

The Harness is a small, versioned reference for durable instructions and
verification contracts. It does not run Codex, manage configuration, or
contain each project's operational commands.

```text
Harness: reusable rules, templates, and documentation
    ↓ reviewed adoption
Project: facts, commands, compatibility boundaries, verification routing
    ↓ normal use
Native Codex + optional project tools: work on the requested outcome
```

Use the nearest owner for every correction:

| Observation | Correct owner |
| --- | --- |
| A personal safety or reporting rule is missing across projects | Global `AGENTS.md` and, if durable, the global template here |
| A project's architecture fact, consumer, command, or compatibility boundary is wrong | that project's nearest `AGENTS.md` or source-of-truth documentation |
| Verification is incomplete or incorrectly routed | that project's `./scripts/verify` and Verification Routing map |
| A generic methodology step is unclear | Native Codex or Superpowers, not duplicate Harness instructions |
| Graph structure is stale or absent | the opted-in repository's Graphify artifacts, guidance, and watcher |
| Credentials, trust, plugin state, or local service configuration is absent | the user-owned local environment, never a portable Harness artifact |

This separation is the safeguard against the Harness becoming a second build
system, a copy of every repository, or a hidden configuration manager.

## Restore the Normal Daily Interface

There is no special startup command. In the target repository, tell Codex the
outcome, constraints, and evidence you need. For example:

```text
Trace the affected invoice consumers, add the audit field, and run the
repository's fast verification for the changed scopes.
```

The project's instructions identify its facts and verification route. Native
Codex handles tools, approvals, and sessions. Use the [daily usage guide](daily-usage.md)
only when you need a persistent goal, a worktree, subagents, review, a hook,
or another named native capability.

Graphify remains optional. Its watcher refreshes code-structure output for a
repository that has explicitly enabled it. A `graphify-out/needs_update`
marker means documentation, PDF, or image semantics may be stale; refresh
them intentionally before relying on those facts. It does not block ordinary
known-file work.

## Make the Next Return Easier

When changing this environment, leave a concise durable record answering:

1. What recurring problem justified the change?
2. Which owner and boundary does it affect?
3. What was intentionally not changed?
4. What command or inspection verified it?
5. What condition would justify revisiting the decision?

Put reusable answers in this Harness. Put project-specific answers in that
project. Keep machine-only facts local. Before promoting a new shared rule or
tool, use it in a real case and confirm that it adds a distinct benefit rather
than duplicating Native Codex, Superpowers, Git, or project tooling.

## What This Repository Cannot Restore

A clone can restore the documented workflow, but it cannot restore an account,
permissions, local trust decision, enabled plugin, connector authorization,
Graphify installation, or a user-level watcher. Those prerequisites are
intentionally outside version control. Rebuild them through their official
setup paths, then verify the local outcome without committing machine-specific
state.

For the full portability boundary, see [configuration ownership](configuration.md)
and [the reference environment](reference-environment.md).
