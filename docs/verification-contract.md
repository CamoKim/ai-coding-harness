# Verification Contract

## Interface

An adopted repository exposes one predictable entry point:

```text
./scripts/verify <scope> <level>
```

The concrete scope names belong to the project. Common levels are:

- `fast`: relevant, low-cost checks suitable for normal iteration;
- `full`: `fast` checks plus relevant higher-cost or environment-dependent checks.

Every adopted subsystem should support `fast`. A subsystem may report `full` as unsupported until it has a safe and meaningful implementation.

Changed-file analysis and automatic level selection are outside v0.1. The caller chooses the scope and level explicitly.

## Repository Verifier

The repository verifier:

- validates the requested scope and level;
- resolves the subsystem verifier for that scope;
- dispatches the request and propagates its result;
- supports an explicit `all` scope by invoking known subsystem verifiers;
- contains no subsystem build, test, lint, or runtime commands.

## Subsystem Verifier

The subsystem verifier:

- owns the actual verification recipe;
- checks required tools and environment before dependent checks;
- prints each command before executing it, without exposing secrets;
- distinguishes checks actually run from checks not run;
- returns a documented non-zero status on failure or unsupported environment;
- avoids modifying application, infrastructure, or production state.

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
