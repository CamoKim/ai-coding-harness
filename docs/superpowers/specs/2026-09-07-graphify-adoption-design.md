# Graphify Adoption Design

## Goal

Replace the bespoke `local-repository-graph` implementation for
`obigo-data-pipeline` with Graphify, while keeping a project graph current
without user-issued update commands. Make the same local Graphify installation
and watcher pattern reusable for later repositories.

## Scope

The first migration covers:

- the local machine's Graphify CLI and Codex integration;
- `obigo-data-pipeline` as the first watched repository;
- removal of the bespoke graph wrapper, configuration, tests, evaluation
  artifacts, and standalone `local-repository-graph` repository; and
- removal or replacement of Harness documents that prescribe the bespoke graph.

It does not add a hosted graph service, external database, CI graph generation,
automatic semantic re-extraction of documents, or Graphify Git hooks.

## Design

### Ownership

Graphify is the repository-structure engine. It extracts and queries a broad
local graph of code, SQL, configuration, and documentation.

The Harness and each repository's `AGENTS.md` remain the owners of durable
facts that Graphify cannot prove from source alone: safety boundaries,
compatibility contracts, consumer review requirements, and verification
routing. Graphify query output is advisory and does not replace targeted source
inspection or project verification.

### Installation and Scope

Install `graphifyy` once in an isolated user-level `uv` tool environment. Its
Codex skill is registered with `graphify codex install --project` from each
repository that opts in. This keeps Graphify's query-first instruction scoped
to that repository while allowing the one local CLI installation to serve all
future repositories.

`obigo-data-pipeline` is the first opt-in project. Its initial graph is created
with `$graphify .` from a Codex session in the repository root.

### Artifact Policy

The team-shared graph artifacts are committed:

- `graphify-out/graph.json`;
- `graphify-out/GRAPH_REPORT.md`; and
- `graphify-out/graph.html` when Graphify produces it.

Local and machine-specific Graphify state is ignored:

- `graphify-out/cache/`;
- `graphify-out/manifest.json`;
- `graphify-out/cost.json`; and
- `graphify-out/needs_update`.

The committed graph gives a fresh checkout immediately queryable structural
context. The ignored state remains a rebuildable cache and must never become a
source of truth.

### Automatic Freshness

A Graphify watcher is the only automatic graph updater. It watches the entire
project path, debounces edit bursts, and regenerates the AST-derived graph when
code changes. It runs as a per-project `systemd --user` service that starts at
login and restarts after failure.

The machine owns a parameterized user service and a small per-project
environment file containing only the repository path. Enabling another
repository consists of creating that environment file and enabling a new
service instance; it does not require a new graph implementation or global
repository configuration.

Do not install Graphify's Git hooks. A post-commit hook updates too late for
uncommitted Codex edits, duplicates watcher work, and adds concurrent write
paths to the same graph artifacts.

Graphify's watcher can automatically refresh code extraction. On documentation,
PDF, or image changes it may create `graphify-out/needs_update` because a
semantic pass needs an agent. The Graphify guidance added to the repository
must instruct Codex to detect this marker for documentation-dependent work and
perform the semantic update before relying on graph-derived documentation
facts. It must not cause an unattended background model/API invocation.

### Repository Guidance

Replace the existing Local Repository Graph section in the target repository's
`AGENTS.md` with concise Graphify guidance:

- skip the graph for known one-file work;
- query the current graph first for ambiguous or cross-cutting work;
- distinguish Graphify extracted, inferred, and ambiguous edges;
- inspect source and apply existing verification routing before acting; and
- refresh a pending semantic graph only when a task depends on changed
  documentation or other non-code assets.

The existing shared-library, schema, SQL, MQTT, and verification rules remain
in `AGENTS.md`; they are not migrated into Graphify configuration.

## Removal

After the Graphify initial build, watcher, Codex registration, and a safe
read-only graph query are verified, remove the bespoke implementation rather
than running two graph engines indefinitely.

Removal covers:

- the `local-repository-graph` Git repository;
- `obigo-data-pipeline/scripts/repository-graph`;
- `.codex/repo-graph.yml` and `.codex/repo-graph-evaluation.yml`;
- repository-graph CLI tests, wrapper design/plan, and evaluation document;
- obsolete `.gitignore` index entries; and
- this Harness's old local-repository-graph design and implementation plan.

Removal is destructive and happens only after the exact paths and clean Git
state are shown and approved. It must not remove `road-platform/sql/011_link_graph.sql`,
whose name refers to domain SQL rather than the AI repository graph.

## Acceptance Criteria

- `graphify --version` succeeds from a new shell.
- Codex recognizes the project Graphify skill and the repository instructions
  remain concise and compatible with existing verification rules.
- A clean checkout contains the committed shared Graphify artifacts and a
  Graphify query can read them without a full rebuild.
- A tracked code-file edit is reflected in the graph by the watcher without a
  user-issued update command.
- The watcher is active after user login and restarts after a controlled
  process stop.
- Local Graphify caches, manifest, costs, and pending-semantic marker do not
  appear as untracked Git changes.
- Graphify Git hooks are absent.
- No bespoke repository-graph wrapper, configuration, tests, plans, or
  standalone repository remains after the migration's verified cutover.

## Risks and Controls

| Risk | Control |
| --- | --- |
| An inferred edge is mistaken for a proven dependency. | Preserve source inspection and verification-routing rules; read Graphify confidence labels. |
| Watcher updates race with agent edits. | Use one per-repository service, debounce changes, and no Git hooks. |
| Documentation graph is stale. | Keep `needs_update` local and require an agent-driven semantic update only when needed. |
| Generated artifacts create noisy diffs. | Commit only the three shared artifacts; ignore cache, manifest, cost, and marker files. |
| Deleting the bespoke graph removes a useful safety rule. | Preserve its durable contract and verification knowledge in `AGENTS.md` before removal. |
