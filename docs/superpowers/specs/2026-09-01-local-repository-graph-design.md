# Local Repository Graph Design

## Goal

Provide a local, reusable repository-graph tool that helps Codex narrow relevant
code, contracts, consumers, and verification scopes for cross-cutting work. The
tool must reduce task-completion time and model context use without reducing
verified task quality.

## Scope

The first adoption target is `obigo-data-pipeline`. The first user is an
interactive, local Codex session. The graph is advisory: it produces a small
set of candidates that Codex verifies by reading current source and running
the repository-owned verifier.

The design does not add CI-triggered agent actions, external indexing,
embeddings, vector search, source uploads, or automatic stateful operations.

## Ownership

The Personal AI Coding Harness remains responsible for durable instructions,
templates, and verification contracts. It does not own graph execution or
project facts.

A separate, reusable local CLI owns graph creation and queries. Each project
owns its tracked graph configuration and its own generated index:

```text
local repository-graph CLI
  build and incremental update commands
  query commands

<project>/.codex/repo-graph.yml
  tracked configuration: sources, project contracts, verifier relationships

<project>/.codex/repo-graph/index.json
  untracked generated index for the current checkout
```

The generated index contains its repository Git SHA, a dirty-tree indicator,
and content hashes for analyzed files. It is not a source of truth and is
never shared between repositories.

## Graph Model

The first graph has these node classes:

- source file and Python module;
- Python symbol definition;
- subsystem and domain;
- executable entry point and Prefect flow;
- test target;
- compatibility contract;
- consumer;
- project verifier scope and CI job.

The first graph has these edge classes:

- module imports module;
- file defines symbol;
- test covers file or symbol;
- entry point invokes flow;
- path or symbol belongs to subsystem;
- change may affect contract or consumer;
- contract requires verifier scope;
- CI job validates path group or scope.

Python AST supplies import, module, and definition edges. Project configuration
supplies edges that static analysis cannot reliably infer: HTTP and MQTT
contracts, schema registries, SQL migrations, Compose configuration, shared
library consumers, verifier routing, and CI job relationships.

Missing or dynamic relationships are represented as uncertainty, never as an
assertion that no impact exists.

## Efficient Query Flow

The system does not use vector search or an LLM to interpret every task.
Those approaches add latency, cost, and another source of stale or opaque
results.

For cross-cutting or initially ambiguous tasks, Codex uses this bounded flow:

```text
task request
  -> small repository map selects a likely subsystem
  -> targeted rg finds one to three seed paths or symbols
  -> graph expands the seed to direct contracts, consumers, tests, and verifiers
  -> Codex reads the selected current source and validates the real impact
```

The graph query output is structured and capped:

- at most three starting files;
- at most twelve related files;
- at most five contracts, consumers, and verification candidates each;
- an explicit index status: `fresh`, `stale`, or `missing`;
- explicit uncertainties for dynamic imports, manual wiring, or incomplete
  configuration.

No source-file bodies are included in graph output. This keeps the output small
enough to be useful as routing context rather than becoming another large
context payload.

For a simple, known one-file task, Codex skips graph lookup and uses the normal
targeted search path.

## Freshness and Fallback

The first build scans configured tracked files. Later builds compare Git diff
and content hashes, then update only changed nodes and their affected edges.

If the queried checkout SHA differs from the index SHA, or a tracked input has
an unmatched hash, the result is `stale`. A stale or missing index never blocks
work: the CLI reports the condition and Codex falls back to the existing
repository map, `rg`, source inspection, and project instructions. Graph
results are candidates, not proof of complete impact analysis.

## Initial obigo-data-pipeline Configuration

The initial configuration covers:

- `onprem/`, `road-platform/`, `aws/`, and `libs/` as top-level subsystems;
- shared-library relationships for `obigo_pipeline_core`, `obigo_vss_core`,
  and `obigo_road_match_core`;
- OnPrem domain and Prefect flow ownership;
- TripInfo/VSS schema registries, SQL migrations, HTTP, MQTT, environment,
  storage, and Compose contracts;
- local `./scripts/verify <onprem|road-platform|all> <fast|full>` routing;
- GitHub Actions `onprem-ci.yml` path groups and validation jobs.

The configuration deliberately treats the existing repository `AGENTS.md`,
current code, tests, migrations, and CI as evidence to reconcile. It does not
infer correctness from stale prose documentation.

## Safety and Privacy

- Analysis and index storage stay on the local machine.
- The index does not read secrets, `.env` files, runtime data, volumes,
  credentials, certificates, or ignored operational directories.
- Building or querying the graph performs no network, deployment, migration,
  Compose lifecycle, data import, or other stateful runtime operation.
- Generated index files are ignored; reviewed configuration and instructions
  remain the durable project artifacts.

## Evaluation

Evaluate the graph on 10 to 20 representative `obigo-data-pipeline` tasks:

- an OnPrem single-domain change;
- a shared-library change;
- a TripInfo or VSS schema change;
- a Road MQTT or SQL contract change;
- a Prefect flow or deployment-wiring change;
- a CI or verifier-routing change.

For each task, compare baseline targeted search with the graph-assisted flow.
Record task-completion time, model input tokens, files and lines read, selected
verification scope, task result, test outcome, and any missed consumer or
contract.

Adoption succeeds only if the graph reduces time and/or tokens while task
quality remains at least equal to the baseline. Quality includes correct
implementation, required verification, review findings, and absence of
identified missed impacts. If quality regresses or gains are negligible, reduce
the graph scope or discontinue the feature rather than treating graph use as a
default.

## Non-goals for the First Release

- complete call-graph correctness for dynamic Python;
- automatic code edits, PR changes, CI retries, or autonomous remediation;
- external services, vector databases, or semantic embeddings;
- graph support for every language before a project needs it;
- replacing repository `AGENTS.md`, tests, CI, or human review.
