# Reference Environment

## Purpose

This document records the intended operating environment for this Harness: why
it exists, which responsibilities each layer owns, and what is deliberately
left outside it. It is a reusable reference, not an installer or a claim that
every machine is configured identically.

The environment is designed to improve outcomes over time by preserving
durable project facts, choosing evidence proportionate to risk, and promoting
only practices that have proved useful in real repositories. It should reduce
rediscovery and unnecessary context without adding a second orchestration
system around Codex.

## Baseline Stack

| Layer | Responsibility | Portable artifact in this repository |
| --- | --- | --- |
| Native Codex CLI | interaction, reasoning, tool use, approvals, sessions, and native capabilities | none; its account, credentials, trust, and local settings remain user-owned |
| Superpowers | generic engineering methodology, such as planning, debugging, TDD, review, and verification discipline | none; it is a separately installed Codex plugin |
| This Harness | durable engineering rules, project and subsystem context, and a project-owned verification contract | `AGENTS.md` templates, documentation, and `./scripts/validate` |
| Each adopted repository | architecture facts, consumers, compatibility boundaries, build/test commands, and verification routing | that repository's `AGENTS.md`, code, documentation, and verifier |
| Graphify (optional) | repository-structure extraction and queries for repositories where broad exploration is useful | a project-scoped skill and committed graph artifacts in the opted-in repository |

The normal interface remains a natural-language request to Codex. There is no
Harness command, wrapper, or custom agent loop to remember. Codex reads the
nearest applicable instructions, uses native capabilities when they help, and
the repository supplies the evidence path for the change.

## Adoption Topology

```text
User-owned Codex account and local configuration
    + Superpowers plugin
    + this Harness's durable templates and reference docs
        ↓ manual, reviewed merge
<repository>/AGENTS.md and optional subsystem AGENTS.md
    + <repository>/scripts/verify
        ↓ optional, per repository
<repository>/.codex Graphify guidance + graphify-out/
```

The Harness is intentionally not a manager for global `AGENTS.md`, Codex
configuration, plugins, credentials, or project locations. Those are local
choices. Its adoption guide describes a careful merge because an existing
project's instructions and verification commands remain the source of truth.

## Graphify: Optional, Per-Project Capability

Graphify is not a graph for this Harness repository or a mandatory global
dependency. A single user-level Graphify CLI can serve multiple repositories,
but each repository explicitly opts in and retains its own graph outputs and
guidance. This keeps graph context close to the code it describes and prevents
unrelated repositories from inheriting exploration cost or instructions.

For an opted-in repository:

1. Register Graphify's Codex guidance in that repository, not globally.
2. Build the initial graph and commit team-useful artifacts such as
   `graphify-out/graph.json`, `graphify-out/GRAPH_REPORT.md`, and `graph.html`
   when produced.
3. Ignore machine-local cache, manifest, cost, path-marker, and
   `needs_update` files.
4. Use one project-specific watcher for automatic code-graph refresh. Do not
   use Graphify Git hooks.
5. Treat Graphify output as navigation evidence, not a replacement for source
   inspection, compatibility review, or the repository verifier.

The first proven adoption is the Obigo data-pipeline repository. Its design and
implementation record are retained here as an example of the reusable pattern:
[Graphify design](superpowers/specs/2026-09-07-graphify-adoption-design.md) and
[adoption plan](superpowers/plans/2026-09-07-graphify-adoption.md). Future
repositories can use the same project-scoped pattern without copying this
repository's configuration into a global Codex setup.

## Deliberate Exclusions

The reference environment excludes tools unless they provide a distinct,
observed benefit beyond the baseline.

- **Headroom** is not part of the baseline. It was evaluated as a Codex proxy,
  then removed rather than making proxy behavior a dependency of ordinary
  work.
- **Ponytail** is deferred. Its small-diff guidance overlaps substantially
  with the existing instruction and methodology layers, so it needs a concrete
  gap before adoption.
- **Installers, doctor commands, and custom orchestration runtimes** are
  excluded. They would manage user-owned configuration or duplicate native
  Codex, Superpowers, Git, and project tooling.

An excluded tool may be reconsidered later, but only with a specific problem,
a bounded trial, and evidence that it improves outcomes without weakening
safety or portability.

## Reproducibility Boundary

Cloning this repository reproduces the policy, templates, documentation, and
source validation. It does not reproduce a person's Codex account, enabled
plugins, connector authorization, local trust decisions, Graphify CLI,
project-specific settings, or user-level service manager state. Those remain
intentional, explicit setup steps.

This boundary makes the Harness useful in four progressively stronger ways:

1. It explains why and how the environment was built.
2. It lets the original user restore the intended workflow from versioned
   documentation.
3. It gives another person reusable templates and a manual adoption path.
4. It can later become fully reproducible only if the local prerequisites and
   per-project optional integrations are deliberately packaged and maintained.

Do not record secrets, usernames, home-directory paths, account identifiers,
or repository locations in portable Harness artifacts. Use the configuration
ownership rules when a future enhancement needs to represent local setup.

## Operating and Improvement Loop

For ordinary work, open Codex at the target repository and state the desired
outcome and constraints. No Graphify command or Harness command is required
for known, focused work. In a Graphify-enabled repository, use graph context
for ambiguous or cross-cutting exploration; its watcher keeps code structure
current while document, PDF, and image changes may still require an intentional
semantic refresh.

When recurring friction appears, first determine whether it is missing project
context, weak verification routing, a local tooling issue, or a genuine shared
pattern. Keep the fix in the narrowest owner that can maintain it. Promote a
pattern into this Harness only after it is durable and useful across more than
one local case.
