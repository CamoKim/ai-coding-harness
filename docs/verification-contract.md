# Verification Contract

## Interface

A project may expose one predictable entry point:

```text
./scripts/verify <scope> <level>
```

The concrete scope names, levels, and implementation belong to the project. Common levels are:

- `fast`: relevant, low-cost checks suitable for normal iteration;
- `full`: `fast` checks plus relevant higher-cost or environment-dependent checks.

Use `fast` for the normal, low-cost evidence available for a scope. A project may report `full` as unsupported until it has safe and meaningful higher-cost evidence.

Codex selects scope and level from the changed files, affected dependencies and contracts, and the repository's Verification Routing rules. The selected project-owned verifier remains the only execution entry point.

## Change-aware Routing

Each adopted repository owns a Verification Routing map that declares, for a changed path or contract source:

- affected verification scopes, including declared direct or transitive consumers of shared dependencies;
- the default level and conditions that require cross-scope or `full` verification;
- runtime evidence, if any, and whether it is isolated or stateful;
- the approval condition for stateful runtime evidence.

Route every affected scope, not just the directory containing the changed file. A routing rule may require only `fast`, may require `full` when the project provides meaningful full verification, or may report `full` as unsupported. Runtime evidence is separate from `./scripts/verify`; selecting a stateful runtime action never authorizes running it.

## Implementation Freedom

The project may map a scope and level directly to existing commands, use a small wrapper, or omit this interface when its current project-owned commands are clearer. It does not need a root dispatcher, per-subsystem scripts, an `all` scope, changed-file inference, or a shared verification framework.

Whatever form a project chooses, keep the actual recipes near the code they validate. Make the checks actually run, checks not run, and unsupported environments observable without exposing secrets. The verifier or documented commands must not modify application, infrastructure, or production state by default.

## Exit Codes

| Code | Meaning |
| --- | --- |
| `0` | All selected checks ran and passed. |
| `1` | One or more selected checks ran and failed. |
| `2` | The requested verification is unsupported in the current implementation or environment. |
| `64` | Invocation error, such as an invalid or missing scope or level. |
| other non-zero | A tool or verifier failed unexpectedly; callers preserve the status. |

An unavailable required environment must not be reported as success. Optional checks may be skipped only when the verifier clearly prints what was skipped and why, and the adopted project contract permits that skip.

## Mutation Boundary

Default verification must not perform stateful or destructive operations, including:

- dependency installation or lockfile updates;
- database migration;
- production or shared service mutation;
- real data import or dataset activation;
- release, deployment, publication, or upload;
- deletion of persistent data, volumes, or generated evidence.

Ephemeral test infrastructure is allowed only when the project owns its lifecycle, isolates it from real data and services, and cleans it up safely.

## Setup Is Separate

Dependency installation, environment bootstrap, credential provisioning, and fixture preparation are setup operations. They must be invoked separately and documented as potentially mutating. Verification may fail with code `2` when required setup is absent.

## Reporting

A verifier should make the following observable:

- requested scope and level;
- commands actually executed;
- pass, fail, unsupported, and permitted skip results;
- relevant limitations or checks not performed.

Passing `fast` must not be described as passing `full`. Unit checks must not be presented as integration or runtime verification.
