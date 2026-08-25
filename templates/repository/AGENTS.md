# Repository Guide

Replace the bracketed prompts with verified repository facts. Remove unused prompts and keep detailed subsystem instructions in the closest subsystem `AGENTS.md`.

## Repository Map

- `[path]`: [responsibility]
- `[path]`: [responsibility]

## Shared Dependencies

- [Identify libraries, schemas, services, or tooling shared by multiple subsystems.]
- [State which consumers require verification when a shared dependency changes.]

## Subsystem Routing

- Work under `[subsystem path]` follows its nearest `AGENTS.md`.
- [Map each subsystem to its instruction file and verification scope.]

## Common Compatibility Contracts

- [List repository-wide APIs, schemas, configuration formats, data contracts, or runtime interfaces.]
- [Link to their sources of truth rather than duplicating detailed specifications.]

## Verification Entry Point

```text
./scripts/verify <scope> <level>
```

- Supported scopes: [list project-owned scopes]
- Supported levels: `fast`, `full`
- [Document any repository-wide verification prerequisites.]

## Verification Routing

Maintain one rule for each path group, shared dependency, or contract source that needs distinct verification.

| Changed path or contract source | Affected scopes | Default level | Escalation | Runtime evidence and approval |
| --- | --- | --- | --- | --- |
| `[path or contract]` | `[scope, consumer scope]` | `fast` | [cross-scope or `full` condition] | `none`, or `[project-owned isolated/stateful action and approval condition]` |

- Shared dependencies: [map each shared component to its declared direct and transitive consumer scopes.]
- Full verification: [state only changes for which the project has meaningful required `full` evidence; record unsupported levels honestly.]
- Runtime evidence: [identify externally observable integration or runtime-path changes and the project-owned evidence action; label stateful actions and required approval.]
- [Routing selects existing project-owned commands. It does not add changed-file inference to `scripts/verify` or authorize stateful operations.]

## Execution Policy Overrides

- Additional `HIGH-RISK` work: [list only work that needs stricter treatment in this repository.]
- Mandatory verification or runtime evidence: [record stricter requirements not already expressed in Verification Routing.]
- Autonomous-operation allowlist or deny list: [state only repository-specific exceptions or restrictions.]
- [These rules may strengthen the Global execution policy; do not repeat it or weaken its approval boundaries.]

## Generated, Runtime, and Secret Data

- Sources of truth: [list source files or directories]
- Generated artifacts: [state how they are generated and whether they are committed]
- Runtime data: [identify directories that verification must not mutate]
- Secrets: [identify example files or environment-variable contracts; never record values]

## Cross-subsystem Impact

- [Describe how to identify and verify affected consumers.]
- [List changes that require more than one subsystem verifier.]
